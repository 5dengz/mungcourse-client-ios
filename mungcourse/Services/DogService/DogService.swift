import Foundation
import Combine
import SwiftUI // For AppStorage if used for token



// MARK: - 에러 타입
enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case httpError(statusCode: Int, data: Data?)
    case decodingError(Error)
    case encodingError(Error)
    case missingToken
    case s3UploadFailed(statusCode: Int?)
}

// MARK: - DogService 구현
class DogService: DogServiceProtocol {
    static let shared = DogService()
    private init() {}

    // API 베이스 URL - 설정에 따라 사용
    private var baseURL: URL {
        if let urlString = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
           !urlString.isEmpty,
           let url = URL(string: urlString) {
            return url
        }
        // 기본 URL
        return URL(string: "https://api.mungcourse.com")!
    }

    // Access token getter
    private var authToken: String? {
        TokenManager.shared.getAccessToken()
    }

    // MARK: - Combine 기반 구현 (첫 번째 파일에서 통합)
    
    // GET /v1/dogs
    func fetchDogs() -> AnyPublisher<[Dog], Error> {
        let endpoint = baseURL.appendingPathComponent("/v1/dogs")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        
        // 토큰 추가
        if let token = authToken, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return Future<[Dog], Error> { promise in
            URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { output -> Data in
                    guard let httpResponse = output.response as? HTTPURLResponse else {
                        throw NetworkError.invalidResponse
                    }
                    let data = output.data
                    switch httpResponse.statusCode {
                    case 200...299:
                        return data
                    case 404:
                        print("[DogService.fetchDogs] 반려견 없음 (404)")
                        return Data() // 빈 바이트로 빈 배열 처리
                    default:
                        throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
                    }
                }
                .tryMap { data -> [Dog] in
                    // 빈 Data는 빈 배열로 변환
                    if data.isEmpty {
                        return []
                    }
                    // 서버 응답 전체 로그
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("[DogService.fetchDogs] 서버 응답: \(jsonString)")
                    }
                    let responseWrapper = try JSONDecoder().decode(DogListResponse.self, from: data)
                    return responseWrapper.data
                }
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            print("[DogService.fetchDogs] 오류: \(error.localizedDescription)")
                            promise(.failure(error))
                        }
                    },
                    receiveValue: { dogs in
                        promise(.success(dogs))
                    }
                )
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }

    // POST /v1/dogs (기본 등록)
    func registerDog(name: String, age: Int, breed: String) -> AnyPublisher<Dog, Error> {
        let endpoint = baseURL.appendingPathComponent("/v1/dogs")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 토큰 추가
        if let token = authToken, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // 요청 바디
        let body: [String: Any] = ["name": name, "age": age, "breed": breed]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        return Future<Dog, Error> { promise in
            URLSession.shared.dataTaskPublisher(for: request)
                .map { $0.data }
                .tryMap { data -> Dog in
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("[DogService.registerDog] 응답: \(jsonString)")
                    }
                    
                    let responseWrapper = try JSONDecoder().decode(DogDataResponse.self, from: data)
                    return responseWrapper.data
                }
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            print("[DogService.registerDog] 오류: \(error.localizedDescription)")
                            promise(.failure(error))
                        }
                    },
                    receiveValue: { dog in
                        promise(.success(dog))
                    }
                )
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Async/Await 기반 구현

    // contentType 매개변수 제거 및 로깅 개선
    func getS3PresignedUrl(fileName: String, fileExtension: String) async throws -> S3PresignedUrlFullResponse {
        let endpoint = baseURL.appendingPathComponent("/v1/s3")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        // Authorization 헤더 추가
        if let token = authToken, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        // Authorization-Refresh 헤더 추가
        if let refresh = TokenManager.shared.getRefreshToken(), !refresh.isEmpty {
            request.setValue("Bearer \(refresh)", forHTTPHeaderField: "Authorization-Refresh")
        }

        let cleanExt = fileExtension.hasPrefix(".")
            ? String(fileExtension.dropFirst())
            : fileExtension
        let body = ["fileName": fileName, "fileNameExtension": cleanExt]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        // —> **로그로 헤더/바디 확인**
        print("➡️ PresignedURL Request: POST \(endpoint.absoluteString)")
        print("🔍 PresignedURL Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        if let b = request.httpBody, let s = String(data: b, encoding: .utf8) {
            print("🔍 PresignedURL Request Body: \(s)")
        }

        let (data, resp) = try await URLSession.shared.data(for: request)

        guard let httpResponse = resp as? HTTPURLResponse else {
            print("❌ Error: Invalid HTTP response received for S3 URL request.")
            throw NetworkError.invalidResponse
        }

        // 응답 상태코드 로깅 개선
        print("📡 S3 URL Request - Status Code: \(httpResponse.statusCode)")
        print("🔍 PresignedURL Response Headers: \(httpResponse.allHeaderFields)")
        if let respBody = String(data: data, encoding: .utf8) {
            print("🔍 PresignedURL Response Body: \(respBody)")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // 오류 응답 상세 로깅
            print("❌ Error: S3 URL request failed with status: \(httpResponse.statusCode)")
            if let errorBody = String(data: data, encoding: .utf8) {
                print("📄 Error response: \(errorBody)")
            }
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(S3PresignedUrlFullResponse.self, from: data)
            print("✅ Received S3 URL Response: preSignedUrl=\(decodedResponse.data.preSignedUrl.prefix(20))..., url=\(decodedResponse.data.url.prefix(20))..., key=\(decodedResponse.data.key)")
            return decodedResponse
        } catch {
            print("❌ Error decoding S3 URL response: \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 Raw response: \(jsonString)")
            }
            throw NetworkError.decodingError(error)
        }
    }

    func uploadImageToS3(presignedUrl: String, imageData: Data) async throws {
        guard let url = URL(string: presignedUrl) else { throw NetworkError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        // Authorization 헤더 추가
        if let token = authToken, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        // Authorization-Refresh 헤더 추가
        if let refresh = TokenManager.shared.getRefreshToken(), !refresh.isEmpty {
            request.setValue("Bearer \(refresh)", forHTTPHeaderField: "Authorization-Refresh")
        }
        // ✅ public-read ACL만 있고
        //    Content-Type: … 호출이 없습니다!
        request.setValue("public-read", forHTTPHeaderField: "x-amz-acl")
        // 크기만 알려주는 건 OK
        request.setValue("\(imageData.count)", forHTTPHeaderField: "Content-Length")
        request.httpBody = imageData

        // —> **로그로 헤더/바디 확인**
        print("➡️ S3 Upload Request: PUT \(request.url?.absoluteString ?? "")")
        print("🔍 S3 Upload Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        print("🔍 S3 Upload Request Body Size: \(imageData.count) bytes")

        let (respData, resp) = try await URLSession.shared.data(for: request)
        guard let httpResponse = resp as? HTTPURLResponse else {
            print("❌ Error: Invalid HTTP response received during S3 upload.")
            throw NetworkError.invalidResponse
        }
        print("🔍 S3 Upload Response Status Code: \(httpResponse.statusCode)")
        print("🔍 S3 Upload Response Headers: \(httpResponse.allHeaderFields)")
        if let bodyString = String(data: respData, encoding: .utf8) {
            print("🔍 S3 Upload Response Body: \(bodyString)")
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ Error: S3 Upload failed with status: \(httpResponse.statusCode)")
            throw NetworkError.s3UploadFailed(statusCode: httpResponse.statusCode)
        }
        print("✅ Image uploaded successfully to S3.")
    }

    func registerDogWithDetails(dogData: DogRegistrationData) async throws -> DogRegistrationResponseData {
        let endpoint = baseURL.appendingPathComponent("/v1/dogs")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let token = authToken, !token.isEmpty else {
             print("❌ Error: Auth token is missing for /v1/dogs request.")
            throw NetworkError.missingToken
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let encoder = JSONEncoder()
            // If server expects specific date format, configure encoder
            // encoder.dateEncodingStrategy = .iso8601 // or .formatted(dateFormatter)
            request.httpBody = try encoder.encode(dogData)
            print("➡️ Registering dog: \(endpoint) with token: \(token.prefix(10))... Body: \(String(data:request.httpBody!, encoding: .utf8) ?? "Invalid Body")")
        } catch {
             print("❌ Error encoding dog registration request body: \(error)")
            throw NetworkError.encodingError(error)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
             print("❌ Error: Invalid HTTP response received for dog registration.")
            throw NetworkError.invalidResponse
        }

        // Check for successful status code (e.g., 200 OK or 201 Created)
        guard (200...299).contains(httpResponse.statusCode) else {
             print("❌ Error: Dog registration failed with status: \(httpResponse.statusCode)")
             if let errorBody = String(data: data, encoding: .utf8) { print("   Error body: \(errorBody)") }
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        // 1) JSON 래퍼를 먼저 파싱
        do {
            let decoder = JSONDecoder()
            // decoder.keyDecodingStrategy = .convertFromSnakeCase // 필요시 사용
            let apiResponse = try decoder.decode(ServiceAPIResponse<DogRegistrationResponseData>.self, from: data)
            let registeredData = apiResponse.data
            print("✅ Dog registered successfully: \(registeredData.name)")
            return registeredData
        } catch {
            print("❌ Error decoding dog registration response: \(error). Data: \(String(data: data, encoding: .utf8) ?? "Invalid data")")
            throw NetworkError.decodingError(error)
        }
    }

    // GET /v1/dogs/main 메인 반려견 조회
    func fetchMainDog() -> AnyPublisher<Dog, Error> {
        let endpoint = baseURL.appendingPathComponent("/v1/dogs/main")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        if let token = authToken, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return Future<Dog, Error> { promise in
            URLSession.shared.dataTaskPublisher(for: request)
                .map { $0.data }
                .tryMap { data -> Dog in
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("[DogService.fetchMainDog] 응답: \(jsonString)")
                    }
                    let responseWrapper = try JSONDecoder().decode(DogDataResponse.self, from: data)
                    return responseWrapper.data
                }
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("[DogService.fetchMainDog] 오류: \(error.localizedDescription)")
                        promise(.failure(error))
                    }
                }, receiveValue: { dog in
                    promise(.success(dog))
                })
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }

    // GET /v1/dogs/{dogId} 강아지 세부 정보 조회
    func fetchDogDetail(dogId: Int) async throws -> DogRegistrationResponseData {
        let endpoint = baseURL.appendingPathComponent("/v1/dogs/\(dogId)")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // 토큰 추가
        guard let token = authToken, !token.isEmpty else {
            print("❌ Error: Auth token is missing for /v1/dogs/{dogId} request.")
            throw NetworkError.missingToken
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1, data: data)
        }
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(ServiceAPIResponse<DogRegistrationResponseData>.self, from: data)
        return apiResponse.data
    }

    // GET /v1/dogs/{dogId}/walks 강아지 산책 기록 조회
    func fetchWalkRecords(dogId: Int) async throws -> [WalkRecordData] {
        let endpoint = baseURL.appendingPathComponent("/v1/dogs/\(dogId)/walks")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let token = authToken, !token.isEmpty else {
            throw NetworkError.missingToken
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1, data: data)
        }
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(ServiceAPIResponse<[WalkRecordData]>.self, from: data)
        return apiResponse.data
    }
}

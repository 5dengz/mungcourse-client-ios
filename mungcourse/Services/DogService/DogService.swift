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
    // 프로필 이미지 S3 삭제
    func deleteProfileImageS3(objectKey: String) async throws {
        let endpoint = baseURL.appendingPathComponent("/v1/s3")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["key": objectKey]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        print("➡️ [DogService.deleteProfileImageS3] DELETE 요청 URL: \(endpoint)")
        print("   [DogService.deleteProfileImageS3] 요청 바디: \(body)")
        let (data, response, error) = await withCheckedContinuation { continuation in
            NetworkManager.shared.performAPIRequest(request) { data, response, error in
                continuation.resume(returning: (data, response, error))
            }
        }
        if let error = error {
            print("❌ [DogService.deleteProfileImageS3] 네트워크 에러: \(error)")
            throw error
        }
        guard let httpResponse = response as? HTTPURLResponse, let data = data else {
            print("❌ [DogService.deleteProfileImageS3] Invalid HTTP response")
            throw NetworkError.invalidResponse
        }
        print("⬅️ [DogService.deleteProfileImageS3] 응답 코드: \(httpResponse.statusCode)")
        if let responseBody = String(data: data, encoding: .utf8) {
            print("⬅️ [DogService.deleteProfileImageS3] 응답 바디: \(responseBody)")
        }
        struct S3DeleteResponse: Decodable {
            let timestamp: String?
            let statusCode: Int?
            let message: String?
            let success: Bool?
        }
        let decoded = try? JSONDecoder().decode(S3DeleteResponse.self, from: data)
        if let decoded = decoded {
            print("[DogService.deleteProfileImageS3] statusCode: \(decoded.statusCode ?? -1), success: \(decoded.success ?? false), message: \(decoded.message ?? "")")
            if decoded.success != true || (decoded.statusCode ?? 0) < 200 || (decoded.statusCode ?? 0) >= 300 {
                throw NetworkError.httpError(statusCode: decoded.statusCode ?? -1, data: data)
            }
        } else {
            print("[DogService.deleteProfileImageS3] 응답 디코딩 실패")
            throw NetworkError.invalidResponse
        }
        print("✅ [DogService.deleteProfileImageS3] S3 이미지 삭제 성공: \(objectKey)")
    }

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
    
    // 메인 반려견 조회 Publisher 구현 (프로토콜 준수)
    func fetchMainDog() -> AnyPublisher<Dog, Error> {
        let endpoint = baseURL.appendingPathComponent("/v1/dogs/main")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        if let token = authToken, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return Future<Dog, Error> { promise in
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
                        print("[DogService.fetchMainDog] 메인 반려견 없음 (404)")
                        throw NetworkError.httpError(statusCode: 404, data: data)
                    default:
                        throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
                    }
                }
                .tryMap { data -> Dog in
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("[DogService.fetchMainDog] 서버 응답: \(jsonString)")
                    }
                    let responseWrapper = try JSONDecoder().decode(DogDataResponse.self, from: data)
                    return responseWrapper.data
                }
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            print("[DogService.fetchMainDog] 오류: \(error.localizedDescription)")
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

    // MARK: - Async/Await 기반 구현

    // getS3PresignedUrl 함수 NetworkManager 적용
    func getS3PresignedUrl(fileName: String, fileExtension: String) async throws -> S3PresignedUrlFullResponse {
        let endpoint = baseURL.appendingPathComponent("/v1/s3")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = authToken, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let refresh = TokenManager.shared.getRefreshToken(), !refresh.isEmpty {
            request.setValue("Bearer \(refresh)", forHTTPHeaderField: "Authorization-Refresh")
        }
        let cleanExt = fileExtension.hasPrefix(".") ? String(fileExtension.dropFirst()) : fileExtension
        let body = ["fileName": fileName, "fileNameExtension": cleanExt]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        print("➡️ PresignedURL Request: POST \(endpoint.absoluteString)")
        print("🔍 PresignedURL Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        if let b = request.httpBody, let s = String(data: b, encoding: .utf8) {
            print("🔍 PresignedURL Request Body: \(s)")
        }
        let (data, response, error) = await withCheckedContinuation { continuation in
            NetworkManager.shared.performAPIRequest(request) { data, response, error in
                continuation.resume(returning: (data, response, error))
            }
        }
        if let error = error {
            print("❌ [DogService.getS3PresignedUrl] 네트워크 에러: \(error)")
            throw error
        }
        guard let httpResponse = response as? HTTPURLResponse, let data = data else {
            print("❌ [DogService.getS3PresignedUrl] Invalid HTTP response")
            throw NetworkError.invalidResponse
        }
        print("📡 S3 URL Request - Status Code: \(httpResponse.statusCode)")
        print("🔍 PresignedURL Response Headers: \(httpResponse.allHeaderFields)")
        if let respBody = String(data: data, encoding: .utf8) {
            print("🔍 PresignedURL Response Body: \(respBody)")
        }
        guard (200...299).contains(httpResponse.statusCode) else {
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

    // uploadImageToS3 함수 NetworkManager 적용
    func uploadImageToS3(presignedUrl: String, imageData: Data) async throws {
        guard let url = URL(string: presignedUrl) else { throw NetworkError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.setValue("\(imageData.count)", forHTTPHeaderField: "Content-Length")
        request.httpBody = imageData
        print("➡️ S3 Upload Request: PUT \(request.url?.absoluteString ?? "")")
        print("🔍 S3 Upload Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        print("🔍 S3 Upload Request Body Size: \(imageData.count) bytes")
        // NetworkManager 사용 금지! URLSession 직접 사용 (Authorization 헤더 자동 추가 방지)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [DogService.uploadImageToS3] Invalid HTTP response")
            throw NetworkError.invalidResponse
        }
        print("🔍 S3 Upload Response Status Code: \(httpResponse.statusCode)")
        print("🔍 S3 Upload Response Headers: \(httpResponse.allHeaderFields)")
        if let str = String(data: data, encoding: .utf8) {
            print("🔍 S3 Upload Response Body: \(str)")
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ Error: S3 Upload failed with status: \(httpResponse.statusCode)")
            throw NetworkError.s3UploadFailed(statusCode: httpResponse.statusCode)
        }
        print("✅ Image uploaded successfully to S3.")
    }

    // registerDogWithDetails 함수 NetworkManager 적용
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
            request.httpBody = try encoder.encode(dogData)
            print("➡️ Registering dog: \(endpoint) with token: \(token.prefix(10))... Body: \(String(data:request.httpBody!, encoding: .utf8) ?? "Invalid Body")")
        } catch {
            print("❌ Error encoding dog registration request body: \(error)")
            throw NetworkError.encodingError(error)
        }
        let (data, response, error) = await withCheckedContinuation { continuation in
            NetworkManager.shared.performAPIRequest(request) { data, response, error in
                continuation.resume(returning: (data, response, error))
            }
        }
        if let error = error {
            print("❌ [DogService.registerDogWithDetails] 네트워크 에러: \(error)")
            throw error
        }
        guard let httpResponse = response as? HTTPURLResponse, let data = data else {
            print("❌ [DogService.registerDogWithDetails] Invalid HTTP response")
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ Error: Dog registration failed with status: \(httpResponse.statusCode)")
            if let errorBody = String(data: data, encoding: .utf8) { print("   Error body: \(errorBody)") }
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }
        do {
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(ServiceAPIResponse<DogRegistrationResponseData>.self, from: data)
            let registeredData = apiResponse.data
            print("✅ Dog registered successfully: \(registeredData.name)")
            return registeredData
        } catch {
            print("❌ Error decoding dog registration response: \(error). Data: \(String(data: data, encoding: .utf8) ?? "Invalid data")")
            throw NetworkError.decodingError(error)
        }
    }

    // fetchDogDetail 함수 NetworkManager 적용
    func fetchDogDetail(dogId: Int) async throws -> DogRegistrationResponseData {
        let endpoint = baseURL.appendingPathComponent("/v1/dogs/\(dogId)")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let token = authToken, !token.isEmpty else {
            print("❌ Error: Auth token is missing for /v1/dogs/{dogId} request.")
            throw NetworkError.missingToken
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response, error) = await withCheckedContinuation { continuation in
            NetworkManager.shared.performAPIRequest(request) { data, response, error in
                continuation.resume(returning: (data, response, error))
            }
        }
        if let error = error {
            print("❌ [DogService.fetchDogDetail] 네트워크 에러: \(error)")
            throw error
        }
        guard let httpResponse = response as? HTTPURLResponse, let data = data else {
            print("❌ [DogService.fetchDogDetail] Invalid HTTP response")
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
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
        let (data, response, error) = await withCheckedContinuation { continuation in
            NetworkManager.shared.performAPIRequest(request) { data, response, error in
                continuation.resume(returning: (data, response, error))
            }
        }
        if let error = error {
            print("❌ [DogService.fetchWalkRecords] 네트워크 에러: \(error)")
            throw error
        }
        guard let httpResponse = response as? HTTPURLResponse, let data = data else {
            print("❌ [DogService.fetchWalkRecords] Invalid HTTP response")
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(ServiceAPIResponse<[WalkRecordData]>.self, from: data)
        return apiResponse.data
    }

    // 강아지 정보 수정
    func updateDog(dogId: Int, dogData: DogRegistrationData) async throws -> DogRegistrationResponseData {
        let endpoint = baseURL.appendingPathComponent("/v1/dogs/\(dogId)")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let token = authToken, !token.isEmpty else {
            print("❌ Error: Auth token is missing for /v1/dogs/{dogId} request.")
            throw NetworkError.missingToken
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(dogData)
            print("➡️ Updating dog: \(endpoint) with token: \(token.prefix(10))")
        } catch {
            print("❌ Error encoding dog update request body: \(error)")
            throw NetworkError.encodingError(error)
        }
        let (data, response, error) = await withCheckedContinuation { continuation in
            NetworkManager.shared.performAPIRequest(request) { data, response, error in
                continuation.resume(returning: (data, response, error))
            }
        }
        if let error = error {
            print("❌ [DogService.updateDog] 네트워크 에러: \(error)")
            throw error
        }
        guard let httpResponse = response as? HTTPURLResponse, let data = data else {
            print("❌ [DogService.updateDog] Invalid HTTP response")
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ Error: Dog update failed with status: \(httpResponse.statusCode)")
            if let errorBody = String(data: data, encoding: .utf8) { print("   Error body: \(errorBody)") }
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }
        do {
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(ServiceAPIResponse<DogRegistrationResponseData>.self, from: data)
            let updated = apiResponse.data
            print("✅ Dog updated successfully: \(updated.name)")
            return updated
        } catch {
            print("❌ Error decoding dog update response: \(error)")
            throw NetworkError.decodingError(error)
        }
    }

    // 강아지 정보 삭제
    func deleteDog(dogId: Int) async throws {
        let endpoint = baseURL.appendingPathComponent("/v1/dogs/\(dogId)")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "DELETE"
        guard let token = authToken, !token.isEmpty else {
            print("❌ [DogService.deleteDog] Auth token is missing for DELETE /v1/dogs/{dogId} request.")
            throw NetworkError.missingToken
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("➡️ [DogService.deleteDog] DELETE 요청 URL: \(endpoint)")
        print("   [DogService.deleteDog] 요청 헤더: \(request.allHTTPHeaderFields ?? [:])")
        let (data, response, error) = await withCheckedContinuation { continuation in
            NetworkManager.shared.performAPIRequest(request) { data, response, error in
                continuation.resume(returning: (data, response, error))
            }
        }
        if let error = error {
            print("❌ [DogService.deleteDog] 네트워크/알 수 없는 에러: \(error)")
            throw error
        }
        guard let httpResponse = response as? HTTPURLResponse, let data = data else {
            print("❌ [DogService.deleteDog] Invalid HTTP response")
            throw NetworkError.invalidResponse
        }
        print("⬅️ [DogService.deleteDog] 응답 코드: \(httpResponse.statusCode)")
        if let responseBody = String(data: data, encoding: .utf8) {
            print("⬅️ [DogService.deleteDog] 응답 바디: \(responseBody)")
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ [DogService.deleteDog] 실패 상태 코드: \(httpResponse.statusCode)")
            if let errorBody = String(data: data, encoding: .utf8), !errorBody.isEmpty {
                print("   [DogService.deleteDog] 에러 바디: \(errorBody)")
            }
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }
        print("✅ [DogService.deleteDog] Dog with ID \(dogId) deleted successfully.")
    }
}

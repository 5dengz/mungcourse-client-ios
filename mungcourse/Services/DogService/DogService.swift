import Foundation
import Combine
import SwiftUI // For AppStorage if used for token

// MARK: - 프로토콜 정의
protocol DogServiceProtocol {
    // Combine 기반 메서드
    func fetchDogs() -> AnyPublisher<[Dog], Error>
    func registerDog(name: String, age: Int, breed: String) -> AnyPublisher<Dog, Error>
    
    // Async/Await 기반 메서드
    func getS3PresignedUrl(fileName: String, fileExtension: String) async throws -> S3PresignedUrlResponse
    func uploadImageToS3(presignedUrl: String, imageData: Data) async throws
    func registerDogWithDetails(dogData: DogRegistrationData) async throws -> Dog
}

// MARK: - 응답 모델
// S3 Pre-signed URL 응답 모델
struct S3PresignedUrlResponse: Decodable {
    let preSignedUrl: String
    let imageUrl: String
}

// API Response Wrappers
private struct DogListResponse: Codable {
    let data: [Dog]
}

private struct DogDataResponse: Codable {
    let data: Dog
}

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

    // Access Token (using AppStorage for simplicity, align with LoginViewModel)
    @AppStorage("authToken") private var authToken: String = ""

    // MARK: - Combine 기반 구현 (첫 번째 파일에서 통합)
    
    // GET /v1/dogs
    func fetchDogs() -> AnyPublisher<[Dog], Error> {
        let endpoint = baseURL.appendingPathComponent("/v1/dogs")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        
        // 토큰 추가
        if !authToken.isEmpty {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }

        return Future<[Dog], Error> { promise in
            URLSession.shared.dataTaskPublisher(for: request)
                .map { $0.data }
                .tryMap { data -> [Dog] in
                    // HTTP 404 처리: 반려견 없음으로 간주하고 빈 배열 반환
                    let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                    if let message = response?["message"] as? String, message.contains("not found") {
                        print("[DogService.fetchDogs] 반려견 없음")
                        return []
                    }
                    
                    // 서버 응답 JSON 전체 로그
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("[DogService.fetchDogs] 서버 응답: \(jsonString)")
                    }
                    
                    // 응답 디코딩
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
        if !authToken.isEmpty {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
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

    func getS3PresignedUrl(fileName: String, fileExtension: String) async throws -> S3PresignedUrlResponse {
        let endpoint = baseURL.appendingPathComponent("/v1/s3")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard !authToken.isEmpty else {
            print("❌ Error: Auth token is missing for /v1/s3 request.")
            throw NetworkError.missingToken
        }
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        let requestBody = ["fileName": fileName, "fileNameExtension": fileExtension]
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            print("➡️ Requesting S3 URL: \(endpoint) with token: \(authToken.prefix(10))... Body: \(String(data:request.httpBody!, encoding: .utf8) ?? "Invalid Body")")
        } catch {
            print("❌ Error encoding S3 URL request body: \(error)")
            throw NetworkError.encodingError(error)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
             print("❌ Error: Invalid HTTP response received for S3 URL request.")
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ Error: S3 URL request failed with status: \(httpResponse.statusCode)")
            if let errorBody = String(data: data, encoding: .utf8) { print("   Error body: \(errorBody)") }
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            let decoder = JSONDecoder()
            // Handle snake_case keys from server if needed
            // decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedResponse = try decoder.decode(S3PresignedUrlResponse.self, from: data)
            print("✅ Received S3 URL Response: preSignedUrl=\(decodedResponse.preSignedUrl.prefix(20))..., imageUrl=\(decodedResponse.imageUrl)")
            return decodedResponse
        } catch {
            print("❌ Error decoding S3 URL response: \(error). Data: \(String(data: data, encoding: .utf8) ?? "Invalid data")")
            throw NetworkError.decodingError(error)
        }
    }

    func uploadImageToS3(presignedUrl: String, imageData: Data) async throws {
        guard let url = URL(string: presignedUrl) else {
             print("❌ Error: Invalid pre-signed URL string: \(presignedUrl)")
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        // Determine Content-Type dynamically or assume JPEG/PNG
        // For more robustness, inspect imageData's first few bytes
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type") // Or "image/png"

        print("⬆️ Uploading image (\(imageData.count) bytes) to S3: \(url.absoluteString.prefix(60))...")

        let (_, response) = try await URLSession.shared.upload(for: request, from: imageData)

        guard let httpResponse = response as? HTTPURLResponse else {
             print("❌ Error: Invalid HTTP response received during S3 upload.")
            throw NetworkError.invalidResponse
        }

        // S3 PUT success is typically 200 OK
        guard httpResponse.statusCode == 200 else {
             print("❌ Error: S3 Upload failed with status: \(httpResponse.statusCode)")
             // Attempt to read error body from S3 (often XML)
             // let (errorData, _) = try await URLSession.shared.data(from: url) // This might not be correct, S3 response might be empty on error
             // print("   S3 Error Body (if any): \(String(data: errorData, encoding: .utf8) ?? "")")
            throw NetworkError.s3UploadFailed(statusCode: httpResponse.statusCode)
        }
        print("✅ Image uploaded successfully to S3.")
    }

    func registerDogWithDetails(dogData: DogRegistrationData) async throws -> Dog {
        let endpoint = baseURL.appendingPathComponent("/v1/dogs")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard !authToken.isEmpty else {
             print("❌ Error: Auth token is missing for /v1/dogs request.")
            throw NetworkError.missingToken
        }
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        do {
            let encoder = JSONEncoder()
            // If server expects specific date format, configure encoder
            // encoder.dateEncodingStrategy = .iso8601 // or .formatted(dateFormatter)
            request.httpBody = try encoder.encode(dogData)
            print("➡️ Registering dog: \(endpoint) with token: \(authToken.prefix(10))... Body: \(String(data:request.httpBody!, encoding: .utf8) ?? "Invalid Body")")
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

        do {
            let decoder = JSONDecoder()
            // Handle potential snake_case keys from server
            // decoder.keyDecodingStrategy = .convertFromSnakeCase
            let registeredDog = try decoder.decode(Dog.self, from: data)
            print("✅ Dog registered successfully: \(registeredDog.name) (ID: \(registeredDog.id))")
            return registeredDog
        } catch {
             print("❌ Error decoding dog registration response: \(error). Data: \(String(data: data, encoding: .utf8) ?? "Invalid data")")
            throw NetworkError.decodingError(error)
        }
    }
} 
import Foundation
import Combine
import SwiftUI // For AppStorage if used for token

// Network Error Enum
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

class DogService: DogServiceProtocol {

    static let shared = DogService()
    private init() {}

    // !!! IMPORTANT: Replace with your actual API base URL !!!
    private let baseURL = URL(string: "https://api.mungcourse.com")!

    // Access Token (using AppStorage for simplicity, align with LoginViewModel)
    // Alternatively, use a dedicated TokenManager/Keychain service
    @AppStorage("authToken") private var authToken: String = ""

    // --- Existing Combine-based functions (Keep or adapt) ---
    func fetchDogs() -> AnyPublisher<[Dog], Error> {
        // Placeholder - Implement using Combine or convert to async/await
        print("⚠️ fetchDogs using Combine is not implemented.")
        return Fail(error: NetworkError.requestFailed(URLError(.badURL))).eraseToAnyPublisher()
    }

    func registerDog(name: String, age: Int, breed: String) -> AnyPublisher<Dog, Error> {
        // Placeholder - This might be replaced by registerDogWithDetails
        print("⚠️ registerDog using Combine is not implemented. Use registerDogWithDetails.")
        return Fail(error: NetworkError.requestFailed(URLError(.badURL))).eraseToAnyPublisher()
    }

    // --- New Async/Await Network Functions ---

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

// Note: TokenManager class is removed as AppStorage is used directly.
// If a more complex token management (like Keychain) is needed,
// re-introduce TokenManager and use it here instead of @AppStorage. 
import Foundation
import Combine

protocol DogServiceProtocol {
    func fetchDogs() -> AnyPublisher<[Dog], Error>
    func registerDog(name: String, age: Int, breed: String) -> AnyPublisher<Dog, Error>
}

final class DogService: DogServiceProtocol {
    static let shared = DogService()
    private static var apiBaseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? ""
    }

    private init() {}

    // GET /v1/dogs
    func fetchDogs() -> AnyPublisher<[Dog], Error> {
        guard let url = URL(string: "\(Self.apiBaseURL)/v1/dogs") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        return Future<[Dog], Error> { promise in
            NetworkManager.shared.performAPIRequest(request) { data, response, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                guard let data = data else {
                    promise(.failure(URLError(.badServerResponse)))
                    return
                }
                do {
                    let responseWrapper = try JSONDecoder().decode(DogListResponse.self, from: data)
                    promise(.success(responseWrapper.data))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    // POST /v1/dogs
    func registerDog(name: String, age: Int, breed: String) -> AnyPublisher<Dog, Error> {
        guard let url = URL(string: "\(Self.apiBaseURL)/v1/dogs") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["name": name, "age": age, "breed": breed]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        return Future<Dog, Error> { promise in
            NetworkManager.shared.performAPIRequest(request) { data, response, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                guard let data = data else {
                    promise(.failure(URLError(.badServerResponse)))
                    return
                }
                do {
                    let responseWrapper = try JSONDecoder().decode(DogDataResponse.self, from: data)
                    promise(.success(responseWrapper.data))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// API Response Wrappers
private struct DogListResponse: Codable {
    let data: [Dog]
}

private struct DogDataResponse: Codable {
    let data: Dog
} 
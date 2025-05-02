import Foundation
import Combine

// MARK: - API response models
struct RoutineListResponse: Decodable {
    let timestamp: String
    let statusCode: Int
    let message: String
    let data: [RoutineData]
    let success: Bool
}

struct RoutineData: Decodable {
    let name: String
    let alarmTime: String
    let isCompleted: Bool
    let date: String
    let routineCheckId: Int
    let routineId: Int
}

struct CreateRoutineRequest: Encodable {
    let name: String
    let alarmTime: String
    let repeatDays: [String]
}

struct CreateRoutineResponse: Decodable {
    let name: String
    let alarmTime: String
    let repeatDays: [String]
}

// MARK: - RoutineService
class RoutineService {
    static let shared = RoutineService()
    private init() {}

    private var baseURL: URL {
        if let urlString = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
           !urlString.isEmpty,
           let url = URL(string: urlString) {
            return url
        }
        return URL(string: "https://api.mungcourse.com")!
    }

    /// Fetch routines for a specific date (format: yyyy-MM-dd)
    func fetchRoutines(date: String) -> AnyPublisher<[RoutineData], Error> {
        var components = URLComponents(url: baseURL.appendingPathComponent("/v1/routines"), resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "date", value: date)]
        guard let url = components?.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        return Future<[RoutineData], Error> { promise in
            NetworkManager.shared.performAPIRequest(request) { data, response, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                guard let httpResp = response as? HTTPURLResponse,
                      let data = data else {
                    promise(.failure(URLError(.badServerResponse)))
                    return
                }
                guard (200...299).contains(httpResp.statusCode) else {
                    promise(.failure(URLError(.badServerResponse)))
                    return
                }
                do {
                    let wrapper = try JSONDecoder().decode(RoutineListResponse.self, from: data)
                    promise(.success(wrapper.data))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// Create a new routine
    func createRoutine(requestBody: CreateRoutineRequest) -> AnyPublisher<CreateRoutineResponse, Error> {
        let endpoint = baseURL.appendingPathComponent("/v1/routines")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }

        return Future<CreateRoutineResponse, Error> { promise in
            NetworkManager.shared.performAPIRequest(request) { data, response, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                guard let httpResp = response as? HTTPURLResponse,
                      let data = data else {
                    promise(.failure(URLError(.badServerResponse)))
                    return
                }
                guard (200...299).contains(httpResp.statusCode) else {
                    promise(.failure(URLError(.badServerResponse)))
                    return
                }
                do {
                    let decoded = try JSONDecoder().decode(CreateRoutineResponse.self, from: data)
                    promise(.success(decoded))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
} 
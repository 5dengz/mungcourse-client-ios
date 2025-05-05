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

    enum CodingKeys: String, CodingKey {
        case name, alarmTime, date, routineCheckId, routineId, isCompleted
    }
}

struct CreateRoutineRequest: Encodable {
    let name: String
    let alarmTime: String
    let repeatDays: [String]
    let isAlarmActive: Bool
}

struct CreateRoutineResponse: Decodable {
    let name: String
    let alarmTime: String
    let repeatDays: [String]
    let isAlarmActive: Bool
}

// MARK: - Update Routine
struct UpdateRoutineRequest: Encodable {
    let name: String
    let alarmTime: String
    let repeatDays: [String]
    let isAlarmActive: Bool
    let applyFromDate: String
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
                    let decoder = JSONDecoder()
                    let wrapper = try decoder.decode(RoutineListResponse.self, from: data)
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

    /// Update an existing routine
    func updateRoutine(routineId: Int, requestBody: UpdateRoutineRequest) -> AnyPublisher<Void, Error> {
        let endpoint = baseURL.appendingPathComponent("/v1/routines/\(routineId)")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return Future<Void, Error> { promise in
            NetworkManager.shared.performAPIRequest(request) { data, response, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                guard let httpResp = response as? HTTPURLResponse,
                      (200...299).contains(httpResp.statusCode) else {
                    promise(.failure(URLError(.badServerResponse)))
                    return
                }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    /// Delete an existing routine
    func deleteRoutine(routineId: Int) -> AnyPublisher<Void, Error> {
        let endpoint = baseURL.appendingPathComponent("/v1/routines/\(routineId)")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "DELETE"
        return Future<Void, Error> { promise in
            NetworkManager.shared.performAPIRequest(request) { data, response, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                guard let httpResp = response as? HTTPURLResponse,
                      (200...299).contains(httpResp.statusCode) else {
                    promise(.failure(URLError(.badServerResponse)))
                    return
                }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    /// Toggle routine check/uncheck
    func toggleRoutineCheck(routineCheckId: Int) -> AnyPublisher<Void, Error> {
        let endpoint = baseURL.appendingPathComponent("/v1/routines/\(routineCheckId)/toggle")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["routineCheckId": routineCheckId]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return Future<Void, Error> { promise in
            NetworkManager.shared.performAPIRequest(request) { data, response, error in
                if let error = error {
                    promise(.failure(error)); return
                }
                guard let httpResp = response as? HTTPURLResponse,
                      (200...299).contains(httpResp.statusCode) else {
                    promise(.failure(URLError(.badServerResponse))); return
                }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
}
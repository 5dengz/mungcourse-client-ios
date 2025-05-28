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
    let isAlarmActive: Bool
    let date: String
    let routineCheckId: Int
    let routineId: Int

    enum CodingKeys: String, CodingKey {
        case name, alarmTime, date, routineCheckId, routineId, isCompleted, isAlarmActive
    }
}

struct CreateRoutineRequest: Encodable {
    let name: String
    let alarmTime: String
    let repeatDays: [String]
    let isAlarmActive: Bool
}

struct CreateRoutineResponse: Decodable {
    let id: Int
    let name: String
    let alarmTime: String
    let repeatDays: [String]
    let isAlarmActive: Bool
}

// Wrapper for CreateRoutineResponse to match API response structure
struct CreateRoutineResponseWrapper: Decodable {
    let data: CreateRoutineResponse
}

// MARK: - Update Routine
struct UpdateRoutineRequest: Encodable {
    let name: String
    let alarmTime: String
    let repeatDays: [String]
    let isAlarmActive: Bool
    let applyFromDate: String
}

// MARK: - Toggle Routine Response
struct ToggleRoutineResponse: Decodable {
    let isCompleted: Bool
    let routineCheckId: Int
}

struct ToggleRoutineResponseWrapper: Decodable {
    let timestamp: String
    let statusCode: Int
    let message: String
    let data: ToggleRoutineResponse
    let success: Bool
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
                    
                    // 디버깅용 로그 (NetworkManager 로그와 중복 제거)
                    print("[RoutineService] 파싱된 루틴 개수: \(wrapper.data.count)")
                    wrapper.data.enumerated().forEach { index, routine in
                        print("[RoutineService] 루틴 \(index): name=\(routine.name), routineId=\(routine.routineId), routineCheckId=\(routine.routineCheckId), isCompleted=\(routine.isCompleted)")
                    }
                    
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
                    let wrapper = try JSONDecoder().decode(CreateRoutineResponseWrapper.self, from: data)
                    promise(.success(wrapper.data))
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
    func toggleRoutineCheck(routineCheckId: Int) -> AnyPublisher<ToggleRoutineResponse, Error> {
        let endpoint = baseURL.appendingPathComponent("/v1/routines/\(routineCheckId)/toggle")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "PATCH"
        
        print("[RoutineService] Toggling routine check for routineCheckId: \(routineCheckId)")
        
        return Future<ToggleRoutineResponse, Error> { promise in
            NetworkManager.shared.performAPIRequest(request) { data, response, error in
                if let error = error {
                    print("[RoutineService] Toggle error: \(error.localizedDescription)")
                    promise(.failure(error))
                    return
                }
                guard let httpResp = response as? HTTPURLResponse,
                      let data = data else {
                    print("[RoutineService] Toggle bad response")
                    promise(.failure(URLError(.badServerResponse)))
                    return
                }
                guard (200...299).contains(httpResp.statusCode) else {
                    print("[RoutineService] Toggle HTTP error: \(httpResp.statusCode)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("[RoutineService] Toggle error response: \(responseString)")
                    }
                    promise(.failure(URLError(.badServerResponse)))
                    return
                }
                do {
                    let wrapper = try JSONDecoder().decode(ToggleRoutineResponseWrapper.self, from: data)
                    
                    // 디버깅용 로그 (NetworkManager 로그와 중복 제거)
                    print("[RoutineService] Toggle success: routineCheckId=\(wrapper.data.routineCheckId), isCompleted=\(wrapper.data.isCompleted)")
                    
                    promise(.success(wrapper.data))
                } catch {
                    print("[RoutineService] Toggle JSON error: \(error.localizedDescription)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("[RoutineService] Toggle response data: \(responseString)")
                    }
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
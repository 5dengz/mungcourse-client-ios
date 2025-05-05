import Foundation
import Combine

class WalkService {
    static let shared = WalkService()
    private init() {}
    
    private let baseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? "https://api.mungcourse.com"
    
    // 최근 산책 기록 가져오기
    func fetchRecentWalk() -> AnyPublisher<Walk, Error> {
        guard let url = URL(string: "\(baseURL)/v1/walks/recent") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return Future<Walk, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(URLError(.unknown)))
                return
            }
            
            NetworkManager.shared.performAPIRequest(request) { data, response, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    promise(.failure(URLError(.badServerResponse)))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    promise(.failure(URLError(.badServerResponse)))
                    return
                }
                
                guard let data = data else {
                    promise(.failure(URLError(.zeroByteResource)))
                    return
                }
                
                do {
                    let walkResponse = try JSONDecoder().decode(WalkResponse.self, from: data)
                    promise(.success(walkResponse.data))
                } catch {
                    print("JSON 디코딩 오류: \(error)")
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
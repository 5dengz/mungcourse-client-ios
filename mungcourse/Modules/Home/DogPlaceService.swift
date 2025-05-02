import Foundation
import SwiftUI

// MARK: - DogPlaceService (네트워크 통신 담당)
class DogPlaceService {
    static let shared = DogPlaceService()
    private init() {}

    // API Base URL은 Info.plist에서 가져오도록 설계 (보안 및 환경별 분리)
    private var baseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? ""
    }

    // completion 기반으로 NetworkManager를 통해 요청 (토큰 자동 처리)
    func fetchDogPlaces(currentLat: Double, currentLng: Double, category: String? = nil, completion: @escaping (Result<[DogPlace], Error>) -> Void) {
        guard !baseURL.isEmpty else {
            completion(.failure(URLError(.badURL)))
            return
        }
        var urlComponents = URLComponents(string: baseURL + "/v1/dogPlaces")!
        urlComponents.queryItems = [
            URLQueryItem(name: "currentLat", value: String(currentLat)),
            URLQueryItem(name: "currentLng", value: String(currentLng))
        ]
        if let category = category, !category.isEmpty {
            urlComponents.queryItems?.append(URLQueryItem(name: "category", value: category))
        }
        guard let url = urlComponents.url else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        NetworkManager.shared.performAPIRequest(request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            if httpResponse.statusCode == 200 {
                do {
                    let decoded = try JSONDecoder().decode(DogPlaceResponse.self, from: data)
                    completion(.success(decoded.data))
                } catch {
                    // 디코딩 실패 시 서버 응답 원문을 콘솔에 출력
                    let raw = String(data: data, encoding: .utf8) ?? "(인코딩 불가)"
                    print("[DogPlaceService] 디코딩 실패, 서버 원문 응답: \(raw)")
                    completion(.failure(error))
                }
            } else {
                // 에러 응답 바디를 문자열로 출력 (디버깅)
                let errorString = String(data: data, encoding: .utf8) ?? "알 수 없는 에러"
                print("[DogPlaceService] 서버 에러 응답: \(errorString)")
                completion(.failure(URLError(.userAuthenticationRequired)))
            }
        }
    }
}

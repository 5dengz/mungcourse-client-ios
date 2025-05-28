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
            print("🐾 [DogPlaceService] baseURL이 비어있음")
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
            print("🐾 [DogPlaceService] URL 생성 실패")
            completion(.failure(URLError(.badURL)))
            return
        }

        print("🔍 [DogPlaceService] 반려견 장소 요청: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        NetworkManager.shared.performAPIRequest(request) { data, response, error in
            if let error = error {
                print("❌ [DogPlaceService] 네트워크 오류: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("⚠️ [DogPlaceService] 응답이 HTTPURLResponse가 아님")
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            guard let data = data else {
                print("⚠️ [DogPlaceService] 응답 데이터 없음")
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            print("📤 [DogPlaceService] HTTP 상태 코드: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                do {
                    let decoded = try JSONDecoder().decode(DogPlaceResponse.self, from: data)
                    print("✅ [DogPlaceService] 반려견 장소 조회 성공: \(decoded.data.count)개 항목")
                    for (index, place) in decoded.data.prefix(3).enumerated() {
                        print("   - 장소[\(index)]: \(place.name), 위치: (\(place.lat), \(place.lng)), 거리: \(place.distance)m")
                    }
                    if decoded.data.count > 3 {
                        print("   - ... 외 \(decoded.data.count - 3)개")
                    }
                    completion(.success(decoded.data))
                } catch {
                    // 디코딩 실패 시 서버 응답 원문을 콘솔에 출력
                    let raw = String(data: data, encoding: .utf8) ?? "(인코딩 불가)"
                    print("❌ [DogPlaceService] 디코딩 실패, 서버 원문 응답: \(raw)")
                    print("❌ [DogPlaceService] 디코딩 오류: \(error)")
                    completion(.failure(error))
                }
            } else {
                // 에러 응답 바디를 문자열로 출력 (디버깅)
                let errorString = String(data: data, encoding: .utf8) ?? "알 수 없는 에러"
                print("❌ [DogPlaceService] 서버 에러 응답: \(errorString)")
                completion(.failure(URLError(.userAuthenticationRequired)))
            }
        }
    }
    
    // 장소 이름으로 검색하는 함수
    func searchDogPlaces(currentLat: Double, currentLng: Double, placeName: String, completion: @escaping (Result<[DogPlace], Error>) -> Void) {
        guard !baseURL.isEmpty else {
            print("🐾 [DogPlaceService] 검색 - baseURL이 비어있음")
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var urlComponents = URLComponents(string: baseURL + "/v1/dogPlaces/search")!
        urlComponents.queryItems = [
            URLQueryItem(name: "currentLat", value: String(currentLat)),
            URLQueryItem(name: "currentLng", value: String(currentLng)),
            URLQueryItem(name: "placeName", value: placeName)
        ]
        
        guard let url = urlComponents.url else {
            print("🐾 [DogPlaceService] 검색 - URL 생성 실패")
            completion(.failure(URLError(.badURL)))
            return
        }

        print("🔍 [DogPlaceService] 검색 요청: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        NetworkManager.shared.performAPIRequest(request) { data, response, error in
            if let error = error {
                print("❌ [DogPlaceService] 검색 네트워크 오류: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("⚠️ [DogPlaceService] 검색 응답이 HTTPURLResponse가 아님")
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            guard let data = data else {
                print("⚠️ [DogPlaceService] 검색 응답 데이터 없음")
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            print("📤 [DogPlaceService] 검색 HTTP 상태 코드: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                do {
                    let decoded = try JSONDecoder().decode(DogPlaceResponse.self, from: data)
                    print("✅ [DogPlaceService] 검색 성공: \(decoded.data.count)개 항목")
                    completion(.success(decoded.data))
                } catch {
                    // 디코딩 실패 시 서버 응답 원문을 콘솔에 출력
                    let raw = String(data: data, encoding: .utf8) ?? "(인코딩 불가)"
                    print("❌ [DogPlaceService] 검색 디코딩 실패, 서버 원문 응답: \(raw)")
                    print("❌ [DogPlaceService] 검색 디코딩 오류: \(error)")
                    completion(.failure(error))
                }
            } else {
                // 에러 응답 바디를 문자열로 출력 (디버깅)
                let errorString = String(data: data, encoding: .utf8) ?? "알 수 없는 에러"
                print("❌ [DogPlaceService] 검색 서버 에러 응답: \(errorString)")
                completion(.failure(URLError(.badServerResponse)))
            }
        }
    }
}

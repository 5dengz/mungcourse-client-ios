import Foundation
import NMapsMap

class SmokingZoneService {
    static let shared = SmokingZoneService()
    private init() {}

    private var baseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? ""
    }

    func fetchSmokingZones(currentLat: Double, currentLng: Double, radius: Int = 2000, completion: @escaping (Result<[NMGLatLng], Error>) -> Void) {
        // DogPlaceService와 동일한 방식으로 NetworkManager 사용
        guard let url = URL(string: "\(baseURL)/v1/walks/smokingzone?currentLat=\(currentLat)&currentLng=\(currentLng)") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // JWT 토큰 추가
        if let token = TokenManager.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        print("🚭 [SmokingZoneService] 흡연구역 요청: \(url.absoluteString)")
        NetworkManager.shared.performAPIRequest(request) { data, response, error in
            if let error = error {
                print("❌ [SmokingZoneService] 네트워크 오류: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                print("❌ [SmokingZoneService] 유효하지 않은 응답")
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            print("🚭 [SmokingZoneService] 상태 코드: \(httpResponse.statusCode)")
            if httpResponse.statusCode == 200 {
                do {
                    let decoded = try JSONDecoder().decode(DogPlaceResponse.self, from: data)
                    let zones = decoded.data.map { NMGLatLng(lat: $0.lat, lng: $0.lng) }
                    completion(.success(zones))
                } catch {
                    print("❌ [SmokingZoneService] 디코딩 오류: \(error)")
                    completion(.failure(error))
                }
            } else {
                let raw = String(data: data, encoding: .utf8) ?? ""
                print("🚭 [SmokingZoneService] 비정상 응답: \(httpResponse.statusCode), body=\(raw)")
                completion(.success([]))
            }
        }
    }
}
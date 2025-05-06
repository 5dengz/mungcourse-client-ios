import Foundation
import NMapsMap

// MARK: - 흡연 구역 API 응답 모델
private struct SmokingZoneResponse: Codable {
    let timestamp: String
    let statusCode: Int
    let message: String
    let data: [Coordinate]
    let success: Bool
}

private struct Coordinate: Codable {
    let lat: Double
    let lng: Double
}

class SmokingZoneService {
    static let shared = SmokingZoneService()
    private init() {}

    private var baseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? ""
    }

    func fetchSmokingZones(currentLat: Double, currentLng: Double, radius: Int = 2000, completion: @escaping (Result<[NMGLatLng], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/v1/walks/smokingzone?currentLat=\(currentLat)&currentLng=\(currentLng)") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
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
                    let resp = try JSONDecoder().decode(SmokingZoneResponse.self, from: data)
                    let zones = resp.data.map { NMGLatLng(lat: $0.lat, lng: $0.lng) }
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
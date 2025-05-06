import Foundation
import NMapsMap

class SmokingZoneService {
    static let shared = SmokingZoneService()
    private init() {}

    private var baseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? ""
    }

    func fetchSmokingZones(currentLat: Double, currentLng: Double, radius: Int = 2000, completion: @escaping (Result<[NMGLatLng], Error>) -> Void) {
        let urlString = "\(baseURL)/v1/walks/smokingzone?lat=\(currentLat)&lng=\(currentLng)&radius=\(radius)"
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        print("🚭 [SmokingZoneService] 흡연구역 요청: \(urlString)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { data, response, error in
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
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Double]]
                    let zones = json?.compactMap { dict -> NMGLatLng? in
                        guard let lat = dict["lat"], let lng = dict["lng"] else { return nil }
                        return NMGLatLng(lat: lat, lng: lng)
                    } ?? []
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
        }.resume()
    }
}
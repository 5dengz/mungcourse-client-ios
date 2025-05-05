import Foundation
import CoreLocation
import NMapsMap

// 경로 계산 및 경로 추천 서비스
class RouteService {
    static let shared = RouteService()
    private init() {}
    
    // API Base URL은 Info.plist에서 가져오도록 설계 (보안 및 환경별 분리)
    private var baseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? ""
    }
    
    // 도보 경로 계산 API 호출 (현재 위치에서 경유지를 거쳐 다시 출발지로)
    func calculateWalkingRoute(startLocation: CLLocationCoordinate2D, waypoints: [DogPlace], completion: @escaping (Result<RouteOption, Error>) -> Void) {
        // API 호출 준비
        guard !baseURL.isEmpty else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let urlComponents = URLComponents(string: baseURL + "/v1/routes/walking")!
        
        // 출발지 좌표
        let startLat = String(startLocation.latitude)
        let startLng = String(startLocation.longitude)
        
        // 경유지 좌표들 (JSON 형식으로 직렬화)
        let waypointsData = waypoints.map { place -> [String: Any] in
            return [
                "id": place.id,
                "name": place.name,
                "lat": place.lat,
                "lng": place.lng
            ]
        }
        
        // 데이터 직렬화
        let jsonData: Data
        do {
            let requestBody: [String: Any] = [
                "startLat": startLat,
                "startLng": startLng,
                "waypoints": waypointsData,
                "returnToStart": true  // 시작점으로 돌아오기
            ]
            jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        guard let url = urlComponents.url else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData
        
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
                    let decoded = try JSONDecoder().decode(RouteResponse.self, from: data)
                    
                    // 응답에서 경로 정보 추출
                    let coordinates = self.extractCoordinates(from: decoded)
                    let totalDistance = Double(decoded.data.totalDistance)
                    let estimatedTime = Int(decoded.data.estimatedTime / 60)  // 초 단위를 분 단위로 변환
                    
                    // RouteOption 객체 생성
                    let routeOption = RouteOption(
                        type: .recommended,
                        totalDistance: totalDistance,
                        estimatedTime: estimatedTime,
                        waypoints: waypoints,
                        coordinates: coordinates
                    )
                    
                    completion(.success(routeOption))
                    
                } catch {
                    // 디코딩 실패 시 서버 응답 원문을 콘솔에 출력
                    let raw = String(data: data, encoding: .utf8) ?? "(인코딩 불가)"
                    print("[RouteService] 디코딩 실패, 서버 원문 응답: \(raw)")
                    completion(.failure(error))
                }
            } else {
                // 에러 응답 바디를 문자열로 출력 (디버깅)
                let errorString = String(data: data, encoding: .utf8) ?? "알 수 없는 에러"
                print("[RouteService] 서버 에러 응답: \(errorString)")
                completion(.failure(URLError(.badServerResponse)))
            }
        }
    }
    
    // 임시 경로 생성 (API 개발 전까지 사용할 더미 데이터)
    func createDummyRoute(startLocation: CLLocationCoordinate2D, waypoints: [DogPlace], completion: @escaping (Result<RouteOption, Error>) -> Void) {
        // 시작점
        let startPoint = NMGLatLng(lat: startLocation.latitude, lng: startLocation.longitude)
        
        // 모든 웨이포인트
        let waypointCoords = waypoints.map { NMGLatLng(lat: $0.lat, lng: $0.lng) }
        
        // 경로 생성 (시작 -> 웨이포인트들 -> 시작)
        var routeCoords = [startPoint]
        routeCoords.append(contentsOf: waypointCoords)
        routeCoords.append(startPoint)
        
        // 자연스러운 경로 모양을 위해 중간 점들 추가
        let smoothRoute = addPathSmoothing(routeCoords)
        
        // 거리 계산 (m)
        let distance = calculateDistance(coordinates: smoothRoute)
        
        // 평균 도보 속도를 기준으로 소요 시간 계산 (4km/h = 약 66.7m/분)
        let estimatedTime = Int(distance / 66.7)
        
        let route = RouteOption(
            type: .recommended,
            totalDistance: distance,
            estimatedTime: estimatedTime,
            waypoints: waypoints,
            coordinates: smoothRoute
        )
        
        // 1초 후 결과 전달 (비동기 API 호출 시뮬레이션)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.success(route))
        }
    }
    
    // 좌표 배열 사이에 중간 점들을 추가하여 부드러운 경로 생성
    private func addPathSmoothing(_ coordinates: [NMGLatLng]) -> [NMGLatLng] {
        guard coordinates.count >= 2 else { return coordinates }
        
        var result: [NMGLatLng] = []
        
        for i in 0..<coordinates.count-1 {
            let start = coordinates[i]
            let end = coordinates[i+1]
            
            result.append(start)
            
            // 두 점 사이에 중간점 추가
            for j in 1...3 {
                let fraction = Double(j) / 4.0
                let midLat = start.lat + (end.lat - start.lat) * fraction
                let midLng = start.lng + (end.lng - start.lng) * fraction
                
                // 자연스러운 곡선을 위한 약간의 무작위성
                let latOffset = Double.random(in: -0.0002...0.0002)
                let lngOffset = Double.random(in: -0.0002...0.0002)
                
                let midPoint = NMGLatLng(lat: midLat + latOffset, lng: midLng + lngOffset)
                result.append(midPoint)
            }
        }
        
        // 마지막 점 추가
        result.append(coordinates.last!)
        
        return result
    }
    
    // 좌표 배열의 총 거리 계산 (미터 단위)
    private func calculateDistance(coordinates: [NMGLatLng]) -> Double {
        guard coordinates.count >= 2 else { return 0 }
        
        var totalDistance = 0.0
        
        for i in 0..<coordinates.count-1 {
            let startLocation = CLLocation(latitude: coordinates[i].lat, longitude: coordinates[i].lng)
            let endLocation = CLLocation(latitude: coordinates[i+1].lat, longitude: coordinates[i+1].lng)
            
            totalDistance += startLocation.distance(from: endLocation)
        }
        
        return totalDistance
    }
    
    // API 응답에서 경로 좌표 배열 추출
    private func extractCoordinates(from response: RouteResponse) -> [NMGLatLng] {
        // 경로 정보가 포함된 JSON 배열을 NMGLatLng 배열로 변환
        let pathPoints = response.data.path.map { point -> NMGLatLng in
            return NMGLatLng(lat: point.lat, lng: point.lng)
        }
        
        return pathPoints
    }
}

// API 응답 구조체
struct RouteResponse: Codable {
    let timestamp: String
    let statusCode: Int
    let message: String
    let data: RouteData
    let success: Bool
}

struct RouteData: Codable {
    let totalDistance: Int  // 미터 단위
    let estimatedTime: Int  // 초 단위
    let path: [PathPoint]
}

struct PathPoint: Codable {
    let lat: Double
    let lng: Double
} 
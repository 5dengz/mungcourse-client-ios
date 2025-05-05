import Foundation
import Combine
import SwiftUI
import CoreLocation
import NMapsMap

class RouteSelectionViewModel: ObservableObject {
    @Published var routeOptions: [RouteOption] = []
    @Published var selectedRouteIndex: Int? = nil
    @Published var isLoading = true
    @Published var errorMessage: String? = nil
    @Published var centerCoordinate: NMGLatLng
    @Published var zoomLevel: Double = 14.0
    @Published var pathCoordinates: [NMGLatLng] = []
    @Published var userLocation: NMGLatLng?
    @Published var dangerCoordinates: [NMGLatLng] = [] // 위험 지역(흡연구역) 좌표 배열
    
    private var startLocation: CLLocationCoordinate2D
    private var waypoints: [DogPlace]
    
    init(startLocation: CLLocationCoordinate2D, waypoints: [DogPlace]) {
        self.startLocation = startLocation
        self.waypoints = waypoints
        self.centerCoordinate = NMGLatLng(lat: startLocation.latitude, lng: startLocation.longitude)
        self.userLocation = NMGLatLng(lat: startLocation.latitude, lng: startLocation.longitude)
        
        // 경로 생성
        generateRouteOptions()
    }
    
    private func generateRouteOptions() {
        // 실제 서비스에서는 네이버 지도 API를 통해 경로 계산을 해야 합니다.
        // 현재는 더미 데이터로 예시를 보여줍니다.
        
        // 현재 위치 좌표 변환
        let startLatLng = NMGLatLng(lat: startLocation.latitude, lng: startLocation.longitude)
        
        // 1. 추천 경로 생성
        let recommendedRoute = createRecommendedRoute(startLatLng: startLatLng)
        routeOptions.append(recommendedRoute)
        
        // 2. 최단 경로 생성
        let shortestRoute = createShortestRoute(startLatLng: startLatLng) 
        routeOptions.append(shortestRoute)
        
        // 3. 경치 좋은 경로 생성
        let scenicRoute = createScenicRoute(startLatLng: startLatLng)
        routeOptions.append(scenicRoute)
        
        // 로딩 완료
        isLoading = false
        
        // 기본 경로 선택 (추천 경로)
        if !routeOptions.isEmpty {
            selectRoute(at: 0)
        }
    }
    
    private func createRecommendedRoute(startLatLng: NMGLatLng) -> RouteOption {
        // 웨이포인트 좌표 모으기
        let waypointLatLngs = waypoints.map { NMGLatLng(lat: $0.lat, lng: $0.lng) }
        
        // 경로 생성 (시작점 - 웨이포인트들 - 다시 시작점으로)
        var routeCoordinates = [startLatLng]
        routeCoordinates.append(contentsOf: waypointLatLngs)
        routeCoordinates.append(startLatLng)
        
        // 약간의 변형을 추가해 자연스러운 경로처럼 보이게 함 
        let modifiedCoordinates = addNaturalCurve(to: routeCoordinates)
        
        // 총 거리 계산 (미터 단위)
        let totalDistance = calculateTotalDistance(coordinates: modifiedCoordinates)
        
        // 예상 시간 (평균 걷는 속도를 분당 약 60m로 계산)
        let estimatedTime = Int(totalDistance / 60.0)
        
        return RouteOption(
            type: .recommended,
            totalDistance: totalDistance,
            estimatedTime: estimatedTime,
            waypoints: waypoints,
            coordinates: modifiedCoordinates
        )
    }
    
    private func createShortestRoute(startLatLng: NMGLatLng) -> RouteOption {
        // 웨이포인트 좌표 모으기 (최단 경로를 위해 최적화된 순서)
        let waypointLatLngs = waypoints.map { NMGLatLng(lat: $0.lat, lng: $0.lng) }
        
        // 경로 생성 (시작점 - 웨이포인트들 - 다시 시작점으로)
        var routeCoordinates = [startLatLng]
        routeCoordinates.append(contentsOf: waypointLatLngs)
        routeCoordinates.append(startLatLng)
        
        // 직선 경로 생성 (최단 거리)
        
        // 총 거리 계산 (미터 단위) - 최단 경로라 추천 경로보다 약간 짧게
        let totalDistance = calculateTotalDistance(coordinates: routeCoordinates) * 0.85
        
        // 예상 시간 (평균 걷는 속도를 분당 약 60m로 계산)
        let estimatedTime = Int(totalDistance / 60.0)
        
        return RouteOption(
            type: .shortest,
            totalDistance: totalDistance,
            estimatedTime: estimatedTime,
            waypoints: waypoints,
            coordinates: routeCoordinates
        )
    }
    
    private func createScenicRoute(startLatLng: NMGLatLng) -> RouteOption {
        // 웨이포인트 좌표 모으기
        let waypointLatLngs = waypoints.map { NMGLatLng(lat: $0.lat, lng: $0.lng) }
        
        // 경로 생성 (시작점 - 웨이포인트들 - 다시 시작점으로)
        var routeCoordinates = [startLatLng]
        routeCoordinates.append(contentsOf: waypointLatLngs)
        routeCoordinates.append(startLatLng)
        
        // 경치 좋은 경로는 조금 우회해서 가는 경로라 곡선으로 그리고 약간 길게
        let modifiedCoordinates = addSceneryDetour(to: routeCoordinates)
        
        // 총 거리 계산 (미터 단위) - 경치 좋은 곳을 거치므로 약간 길게
        let totalDistance = calculateTotalDistance(coordinates: modifiedCoordinates) * 1.25
        
        // 예상 시간 (평균 걷는 속도를 분당 약 60m로 계산)
        let estimatedTime = Int(totalDistance / 60.0)
        
        return RouteOption(
            type: .scenic,
            totalDistance: totalDistance,
            estimatedTime: estimatedTime,
            waypoints: waypoints,
            coordinates: modifiedCoordinates
        )
    }
    
    // 좌표들 사이에 자연스러운 곡선을 추가하는 함수
    private func addNaturalCurve(to coordinates: [NMGLatLng]) -> [NMGLatLng] {
        guard coordinates.count >= 2 else { return coordinates }
        
        var result: [NMGLatLng] = []
        
        for i in 0..<coordinates.count-1 {
            let start = coordinates[i]
            let end = coordinates[i+1]
            
            result.append(start)
            
            // 두 점 사이에 중간 점 추가
            let midLat = (start.lat + end.lat) / 2
            let midLng = (start.lng + end.lng) / 2
            
            // 약간의 무작위성 추가
            let latOffset = Double.random(in: -0.0005...0.0005)
            let lngOffset = Double.random(in: -0.0005...0.0005)
            
            let midPoint = NMGLatLng(lat: midLat + latOffset, lng: midLng + lngOffset)
            result.append(midPoint)
        }
        
        // 마지막 점 추가
        result.append(coordinates.last!)
        
        return result
    }
    
    // 경치 좋은 경로를 위해 더 많은 곡선과 우회로를 추가
    private func addSceneryDetour(to coordinates: [NMGLatLng]) -> [NMGLatLng] {
        guard coordinates.count >= 2 else { return coordinates }
        
        var result: [NMGLatLng] = []
        
        for i in 0..<coordinates.count-1 {
            let start = coordinates[i]
            let end = coordinates[i+1]
            
            result.append(start)
            
            // 두 점 사이에 여러 중간 점 추가
            for j in 1...3 {
                let fraction = Double(j) / 4.0
                let baseLat = start.lat + (end.lat - start.lat) * fraction
                let baseLng = start.lng + (end.lng - start.lng) * fraction
                
                // 우회 경로를 표현하기 위해 더 큰 무작위성 추가
                let latOffset = Double.random(in: -0.001...0.001)
                let lngOffset = Double.random(in: -0.001...0.001)
                
                let midPoint = NMGLatLng(lat: baseLat + latOffset, lng: baseLng + lngOffset)
                result.append(midPoint)
            }
        }
        
        // 마지막 점 추가
        result.append(coordinates.last!)
        
        return result
    }
    
    // 두 점 사이의 대략적인 거리 계산 (미터 단위)
    private func calculateDistance(from: NMGLatLng, to: NMGLatLng) -> Double {
        let fromLocation = CLLocation(latitude: from.lat, longitude: from.lng)
        let toLocation = CLLocation(latitude: to.lat, longitude: to.lng)
        return fromLocation.distance(from: toLocation)
    }
    
    // 경로의 총 거리 계산
    private func calculateTotalDistance(coordinates: [NMGLatLng]) -> Double {
        guard coordinates.count >= 2 else { return 0 }
        
        var totalDistance = 0.0
        for i in 0..<coordinates.count-1 {
            totalDistance += calculateDistance(from: coordinates[i], to: coordinates[i+1])
        }
        
        return totalDistance
    }
    
    // 경로 선택하기
    func selectRoute(at index: Int) {
        guard index >= 0 && index < routeOptions.count else { return }
        selectedRouteIndex = index
        pathCoordinates = routeOptions[index].coordinates
        
        // 모든 웨이포인트가 보이도록 지도 중심과 줌 레벨 설정
        centerMapToShowAllWaypoints()
    }
    
    // 모든 웨이포인트가 보이도록 지도 중심 설정
    private func centerMapToShowAllWaypoints() {
        guard let selectedRoute = selectedRouteIndex, 
              !routeOptions[selectedRoute].coordinates.isEmpty else { return }
        
        // 모든 좌표 중 중심점 찾기
        let coordinates = routeOptions[selectedRoute].coordinates
        var minLat = coordinates[0].lat
        var maxLat = coordinates[0].lat
        var minLng = coordinates[0].lng
        var maxLng = coordinates[0].lng
        
        for coord in coordinates {
            minLat = min(minLat, coord.lat)
            maxLat = max(maxLat, coord.lat)
            minLng = min(minLng, coord.lng)
            maxLng = max(maxLng, coord.lng)
        }
        
        // 중심점 계산
        let centerLat = (minLat + maxLat) / 2
        let centerLng = (minLng + maxLng) / 2
        centerCoordinate = NMGLatLng(lat: centerLat, lng: centerLng)
        
        // 적절한 줌 레벨 설정 (간단한 계산)
        let latDiff = maxLat - minLat
        let lngDiff = maxLng - minLng
        let maxDiff = max(latDiff, lngDiff)
        
        // 경험적으로 결정된 적절한 줌 레벨 설정
        if maxDiff > 0.05 {
            zoomLevel = 12.0
        } else if maxDiff > 0.02 {
            zoomLevel = 13.0
        } else if maxDiff > 0.01 {
            zoomLevel = 14.0
        } else {
            zoomLevel = 15.0
        }
    }
}
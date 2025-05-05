import Foundation
import Combine
import SwiftUI
import NMapsMap

class WalkCompleteViewModel: ObservableObject {
    // 산책 데이터
    @Published var distance: String = "0.0"
    @Published var duration: String = "00:00"
    @Published var calories: String = "0"
    @Published var walkDate: Date = Date()
    
    // 지도 관련 데이터
    @Published var pathCoordinates: [NMGLatLng] = []
    @Published var centerCoordinate: NMGLatLng = NMGLatLng(lat: 37.5666, lng: 126.9780)
    @Published var zoomLevel: Double = 15.0
    @Published var dangerCoordinates: [NMGLatLng] = [] // 위험 지역 좌표 리스트
    
    // 로딩 및 오류 상태
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // 서비스 의존성
    private var cancellables = Set<AnyCancellable>()
    private var walkId: Int? = nil // 산책 ID (API 응답에서 받은 값)
    
    // MARK: - 초기화
    
    init(walkData: WalkSessionData? = nil) {
        // 산책 데이터가 제공된 경우 사용
        if let data = walkData {
            setupWithWalkData(data)
        } else {
            // 테스트용 더미 데이터
            setupWithDummyData()
        }
    }
    
    // MARK: - 메서드
    
    // 산책 데이터로 초기화
    private func setupWithWalkData(_ data: WalkSessionData) {
        distance = formatDistance(data.distance)
        duration = formatDuration(data.duration)
        calories = formatCalories(calculateCalories(distance: data.distance, duration: data.duration))
        walkDate = data.date
        
        if !data.coordinates.isEmpty {
            pathCoordinates = data.coordinates
            // 경로 중심점 계산
            centerCoordinate = calculateCenterCoordinate(coordinates: data.coordinates)
            
            // 지도 줌 레벨 계산 (경로의 범위에 맞게)
            calculateZoomLevel(coordinates: data.coordinates)
        }
    }
    
    // 테스트용 더미 데이터
    private func setupWithDummyData() {
        let today = Date()
        walkDate = today
        distance = "1.2"
        duration = "00:05:10"
        calories = "25"
        
        // 더미 경로 데이터 (서울 시청 주변)
        pathCoordinates = [
            NMGLatLng(lat: 37.566, lng: 126.978),
            NMGLatLng(lat: 37.567, lng: 126.979),
            NMGLatLng(lat: 37.568, lng: 126.980),
            NMGLatLng(lat: 37.569, lng: 126.981)
        ]
        
        // 경로 중심점 계산
        centerCoordinate = calculateCenterCoordinate(coordinates: pathCoordinates)
    }
    
    // 홈으로 이동 액션을 ViewModel에서 관리
    func navigateToHome() {
        // 여기서는 간단한 로그만 출력
        // 실제 구현에서는 NavigationPath 또는 콜백을 통해 화면 전환 처리
        print("홈으로 이동")
    }
    
    // API 기본 URL 설정
    private static var apiBaseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? ""
    }
    
    // MARK: - 포맷팅 헬퍼 메서드
    
    private func formatDistance(_ distance: Double) -> String {
        return String(format: "%.1f", distance)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func formatCalories(_ calories: Double) -> String {
        return String(format: "%.0f", calories)
    }
    
    private func calculateCalories(distance: Double, duration: Int) -> Double {
        // 간단한 계산식: 1km당 약 50kcal 소비 가정 (70kg 성인)
        return distance * 50
    }
    
    // MARK: - 지도 관련 헬퍼 메서드
    
    private func calculateCenterCoordinate(coordinates: [NMGLatLng]) -> NMGLatLng {
        guard !coordinates.isEmpty else {
            return NMGLatLng(lat: 37.5666, lng: 126.9780) // 서울 시청 좌표 기본값
        }
        
        var sumLat: Double = 0
        var sumLng: Double = 0
        
        for coord in coordinates {
            sumLat += coord.lat
            sumLng += coord.lng
        }
        
        return NMGLatLng(
            lat: sumLat / Double(coordinates.count),
            lng: sumLng / Double(coordinates.count)
        )
    }
    
    private func calculateZoomLevel(coordinates: [NMGLatLng]) {
        guard coordinates.count > 1 else {
            zoomLevel = 15.0
            return
        }
        
        // 좌표 범위 계산
        var minLat = Double.greatestFiniteMagnitude
        var maxLat = -Double.greatestFiniteMagnitude
        var minLng = Double.greatestFiniteMagnitude
        var maxLng = -Double.greatestFiniteMagnitude
        
        for coord in coordinates {
            minLat = min(minLat, coord.lat)
            maxLat = max(maxLat, coord.lat)
            minLng = min(minLng, coord.lng)
            maxLng = max(maxLng, coord.lng)
        }
        
        // 경로의 크기에 따른 줌 레벨 계산 (간단한 휴리스틱)
        let latDiff = maxLat - minLat
        let lngDiff = maxLng - minLng
        let maxDiff = max(latDiff, lngDiff)
        
        if maxDiff < 0.005 {
            zoomLevel = 17.0 // 작은 경로
        } else if maxDiff < 0.01 {
            zoomLevel = 16.0 // 중간 경로
        } else if maxDiff < 0.05 {
            zoomLevel = 14.0 // 큰 경로
        } else {
            zoomLevel = 12.0 // 매우 큰 경로
        }
    }
}
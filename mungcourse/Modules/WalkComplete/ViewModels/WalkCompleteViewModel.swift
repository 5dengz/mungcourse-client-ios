import Foundation
import Combine
import SwiftUI
import NMapsMap

class WalkCompleteViewModel: ObservableObject {
    // MARK: - Published 속성
    
    // 산책 결과 데이터
    @Published var distance: String = "0.0"
    @Published var duration: String = "00:00:00"
    @Published var calories: String = "0"
    @Published var walkDate: Date = Date()
    
    // 맵 관련 데이터
    @Published var pathCoordinates: [NMGLatLng] = []
    @Published var centerCoordinate: NMGLatLng = NMGLatLng(lat: 37.5665, lng: 126.9780)
    @Published var zoomLevel: Double = 16.0
    
    // 피드백 관련 상태
    @Published var feedbackRating: Int = 0
    @Published var isFeedbackModalPresented = false
    @Published var isFeedbackSubmitted = false
    
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
    
    // 피드백 모달 표시
    func showFeedbackModal() {
        isFeedbackModalPresented = true
    }
    
    // 피드백 모달 닫기
    func closeFeedbackModal() {
        isFeedbackModalPresented = false
    }
    
    // 피드백 등급 설정
    func setFeedbackRating(_ rating: Int) {
        feedbackRating = rating
    }
    
    // 피드백 제출
    func submitFeedback() {
        guard feedbackRating > 0 else { return }
        
        isLoading = true
        
        // API를 통해 피드백 등급 업데이트
        updateWalkRating(rating: feedbackRating) { [weak self] success in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if success {
                    print("✅ 산책 평가 업데이트 성공: \(self.feedbackRating)점")
                    self.isFeedbackSubmitted = true
                } else {
                    print("❌ 산책 평가 업데이트 실패")
                    self.errorMessage = "산책 평가 업데이트에 실패했습니다. 다시 시도해주세요."
                }
                
                self.closeFeedbackModal()
            }
        }
    }
    
    // 산책 평가 업데이트 API 호출
    private func updateWalkRating(rating: Int, completion: @escaping (Bool) -> Void) {
        // TODO: 실제 산책 ID를 사용해야 함 (현재는 임시 구현)
        // API 엔드포인트: PATCH /v1/walks/{walkId}/rating
        
        // 현재는 간단히 네트워크 요청을 시뮬레이션
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // 성공 시뮬레이션
            completion(true)
        }
        
        // 실제 구현 예시:
        /*
        guard let walkId = walkId else {
            print("❌ 산책 ID가 없어 평가 업데이트 불가")
            completion(false)
            return
        }
        
        guard let url = URL(string: "\(Self.apiBaseURL)/v1/walks/\(walkId)/rating") else {
            print("❌ 산책 평가 업데이트 실패: 잘못된 URL")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["rating": rating]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("❌ 산책 평가 JSON 변환 실패: \(error)")
            completion(false)
            return
        }
        
        NetworkManager.shared.performAPIRequest(request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ 산책 평가 업데이트 실패: \(error)")
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ 산책 평가 업데이트 실패: 응답 없음")
                    completion(false)
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    print("✅ 산책 평가 업데이트 성공: \(rating)점")
                    completion(true)
                } else {
                    print("❌ 산책 평가 업데이트 실패: 상태 코드 \(httpResponse.statusCode)")
                    completion(false)
                }
            }
        }
        */
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
    
    // MARK: - 헬퍼 메서드
    
    // 거리 포맷팅
    private func formatDistance(_ distanceInKm: Double) -> String {
        return String(format: "%.1f", distanceInKm)
    }
    
    // 지속 시간 포맷팅
    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
    
    // 칼로리 계산 (간단한 예시)
    private func calculateCalories(distance: Double, duration: Int) -> Int {
        // 간단한 칼로리 계산식 (실제는 더 복잡할 수 있음)
        // 예: 1km당 100칼로리 소모
        return Int(distance * 100)
    }
    
    // 칼로리 포맷팅
    private func formatCalories(_ calories: Int) -> String {
        return "\(calories)"
    }
    
    // 좌표 중심점 계산
    private func calculateCenterCoordinate(coordinates: [NMGLatLng]) -> NMGLatLng {
        guard !coordinates.isEmpty else {
            return NMGLatLng(lat: 37.5665, lng: 126.9780) // 서울 시청 (기본값)
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
    
    // 적절한 줌 레벨 계산
    private func calculateZoomLevel(coordinates: [NMGLatLng]) {
        guard coordinates.count >= 2 else {
            zoomLevel = 16.0 // 기본 줌 레벨
            return
        }
        
        // 경로의 경계 박스 계산
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
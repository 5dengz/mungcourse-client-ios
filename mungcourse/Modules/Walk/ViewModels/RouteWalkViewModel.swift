import Foundation
import Combine
import CoreLocation
import NMapsMap

class RouteWalkViewModel: ObservableObject {
    // 지도 관련 상태
    @Published var centerCoordinate: NMGLatLng
    @Published var zoomLevel: Double = 15.0
    @Published var pathCoordinates: [NMGLatLng]
    @Published var userLocation: NMGLatLng?
    
    // 산책 상태 관련
    @Published var isWalking: Bool = false
    @Published var isPaused: Bool = false
    @Published var totalDistance: Double = 0
    @Published var elapsedTime: Int = 0 // 초 단위
    @Published var calories: Double = 0
    
    // 경로 관련
    @Published var plannedRoute: RouteOption
    @Published var completionPercentage: Double = 0
    @Published var nextWaypointIndex: Int = 0
    
    // 위치 권한 관련
    @Published var showPermissionAlert: Bool = false
    @Published var showLocationErrorAlert: Bool = false
    @Published var locationErrorMessage: String = ""
    
    // 내부 속성
    private var locationManager: GlobalLocationManager
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var trackingPath: [NMGLatLng] = []
    private var lastLocation: CLLocation?
    private var walkSession: WalkSession?
    
    init(route: RouteOption) {
        self.plannedRoute = route
        self.pathCoordinates = route.coordinates
        
        // 시작 위치 설정
        if !route.coordinates.isEmpty {
            self.centerCoordinate = route.coordinates[0]
        } else {
            // 기본 위치 (서울 시청)
            self.centerCoordinate = NMGLatLng(lat: 37.5666103, lng: 126.9783882)
        }
        
        // 싱글톤 인스턴스 사용
        self.locationManager = GlobalLocationManager.shared
        
        // 위치 업데이트 구독
        locationManager.$lastLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.userLocation = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
                self?.handleLocationUpdate(location)
            }
            .store(in: &cancellables)
            
        // 위치 권한 상태 구독
        locationManager.$authorizationStatus
            .sink { [weak self] status in
                self?.handleAuthorizationStatusChange(status)
            }
            .store(in: &cancellables)
            
        // 위치 추적 시작
        self.locationManager.startUpdatingLocation()
    }
    
    // MARK: - 산책 제어 메서드
    
    func startWalk() {
        guard !isWalking else { return }
        
        isWalking = true
        isPaused = false
        
        // 현재 위치부터 경로 추적 시작
        trackingPath.removeAll()
        if let location = locationManager.lastLocation {
            let startPoint = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
            trackingPath.append(startPoint)
        }
        
        // 타이머 시작
        startTimer()
        
        // 세션 생성 - 빈 세션으로 시작
        let startTime = Date()
        walkSession = WalkSession(
            id: UUID(),
            startTime: startTime,
            endTime: startTime, // 일단 같은 시간으로 설정
            duration: 0,
            distance: 0,
            calories: 0,
            path: trackingPath,
            averageSpeed: 0
        )
    }
    
    func pauseWalk() {
        guard isWalking, !isPaused else { return }
        isPaused = true
        stopTimer()
    }
    
    func resumeWalk() {
        guard isWalking, isPaused else { return }
        isPaused = false
        startTimer()
    }
    
    func endWalk() -> WalkSession? {
        guard isWalking else { return nil }
        
        isWalking = false
        isPaused = false
        stopTimer()
        
        guard let session = walkSession else { return nil }
        
        // 현재는 세션 객체를 직접 변경할 수 없으므로 새 세션을 만들어 반환
        let endTime = Date()
        // 평균 속도 계산 (km/h)
        let durationHours = Double(elapsedTime) / 3600.0
        let averageSpeed = durationHours > 0 ? totalDistance / durationHours : 0
        
        let updatedSession = WalkSession(
            id: session.id,
            startTime: session.startTime,
            endTime: endTime,
            duration: Double(elapsedTime),
            distance: totalDistance,
            calories: calories,
            path: trackingPath,
            averageSpeed: averageSpeed
        )
        
        // 위치 추적 정지
        locationManager.stopUpdatingLocation()
        
        return updatedSession
    }
    
    // MARK: - 헬퍼 메서드
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isWalking, !self.isPaused else { return }
            self.elapsedTime += 1
            self.updateCalories()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handleLocationUpdate(_ location: CLLocation) {
        guard isWalking, !isPaused else { return }
        
        // 새 위치를 경로에 추가
        let newPoint = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        trackingPath.append(newPoint)
        
        // 거리 계산
        if let lastLocation = self.lastLocation {
            let distance = location.distance(from: lastLocation) // 미터 단위
            totalDistance += distance / 1000 // km 단위로 변환
        }
        
        // 경로 진행률 계산
        updateRouteProgress(location)
        
        // 현재 위치 저장
        self.lastLocation = location
    }
    
    private func updateRouteProgress(_ currentLocation: CLLocation) {
        guard !plannedRoute.coordinates.isEmpty else { return }
        
        // 남은 웨이포인트와 현재 위치 사이의 최소 거리 계산
        var nearestDistance = Double.greatestFiniteMagnitude
        var nextIndex = nextWaypointIndex
        
        for i in nextWaypointIndex..<plannedRoute.coordinates.count {
            let waypointCoord = plannedRoute.coordinates[i]
            let waypointLocation = CLLocation(latitude: waypointCoord.lat, longitude: waypointCoord.lng)
            let distance = currentLocation.distance(from: waypointLocation)
            
            if distance < nearestDistance {
                nearestDistance = distance
                nextIndex = i
            }
        }
        
        // 20m 이내에 도달했다면 다음 웨이포인트로 업데이트
        if nearestDistance < 20 && nextIndex > nextWaypointIndex {
            nextWaypointIndex = nextIndex
        }
        
        // 전체 경로 진행률 계산
        let progressPercentage = min(1.0, Double(nextWaypointIndex) / Double(plannedRoute.coordinates.count))
        self.completionPercentage = progressPercentage * 100
    }
    
    private func updateCalories() {
        // 칼로리 계산 (간단한 추정 - 보통 사람이 걸을 때 시간당 약 4 칼로리/kg 소모)
        // 70kg인 사람 기준으로 계산
        let weightInKg = 70.0
        let calorieBurnRate = 4.0 // 칼로리/kg/시간
        
        // 초 단위를 시간 단위로 변환
        let hoursElapsed = Double(elapsedTime) / 3600.0
        
        // 칼로리 = 시간 * 소모율 * 체중
        calories = hoursElapsed * calorieBurnRate * weightInKg
    }
    
    private func handleAuthorizationStatusChange(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // 권한 요청 필요
            locationManager.startUpdatingLocation() // 권한 요청 트리거
        case .restricted, .denied:
            // 권한 없음 알림
            showPermissionAlert = true
        case .authorizedAlways, .authorizedWhenInUse:
            // 권한 있음
            showPermissionAlert = false
        @unknown default:
            break
        }
    }
    
    // MARK: - 포맷팅 도우미
    
    var formattedDistance: String {
        return String(format: "%.2f", totalDistance)
    }
    
    var formattedDuration: String {
        let hours = elapsedTime / 3600
        let minutes = (elapsedTime % 3600) / 60
        let seconds = elapsedTime % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var formattedCalories: String {
        return String(format: "%.1f", calories)
    }
    
    var formattedProgress: String {
        return String(format: "%.0f%%", completionPercentage)
    }
    
    // MARK: - API 연동
    
    func uploadWalkSession(_ session: WalkSession, dogIds: [Int], completion: @escaping (Bool) -> Void) {
        // 실제 API 구현 필요
        // WalkTrackingService에서 세션 업로드
        WalkTrackingService.shared.uploadWalkSession(session: session, dogIds: dogIds) { result in
            switch result {
            case .success(_):
                completion(true)
            case .failure(let error):
                print("[RouteWalkViewModel] 산책 세션 업로드 실패: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    deinit {
        stopTimer()
        cancellables.forEach { $0.cancel() }
    }
} 
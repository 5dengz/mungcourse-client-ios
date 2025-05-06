import Foundation
import CoreLocation
import NMapsMap
import Combine

/// Service responsible for tracking walk sessions, including location updates, distance calculations, and session management
class WalkTrackingService: NSObject, ObservableObject {
    // MARK: - Singleton instance
    static let shared = WalkTrackingService()
    
    // MARK: - Published Properties
    @Published var currentLocation: CLLocation?
    @Published var walkPath: [NMGLatLng] = []
    @Published var isTracking: Bool = false
    @Published var distance: Double = 0.0 // in kilometers
    @Published var duration: TimeInterval = 0.0 // in seconds
    @Published var calories: Double = 0.0 // in kcal
    @Published var averageSpeed: Double = 0.0 // in km/h
    
    // MARK: - Private Properties
    private var locationManager: CLLocationManager
    private var timer: Timer?
    private var startTime: Date?
    private var lastLocation: CLLocation?
    private var caloriesPerKmMultiplier: Double = 50.0 // This is a simplified approximation, can be adjusted based on average dog weight and intensity
    
    // MARK: - Initialization
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Location Manager Setup
    private func setupLocationManager() {
        print("[WalkTrackingService] setupLocationManager() 호출")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5 // meters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        requestLocationPermission()
    }
    private func requestLocationPermission() {
        print("[WalkTrackingService] requestLocationPermission() 호출")
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Walk Session Management
    func startWalk(onPermissionDenied: (() -> Void)? = nil) {
        let status = locationManager.authorizationStatus
        print("[WalkTrackingService] startWalk() called, 권한 상태: \(status.rawValue)")
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            print("[WalkTrackingService] 위치 권한이 없습니다. 안내 필요.")
            onPermissionDenied?()
            return
        }
        // 오히려 startWalk 전에 위치 업데이트를 항상 시작하도록 푸시
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
        print("[WalkTrackingService] startWalk() - 데이터 초기화 및 위치 추적 시작")
        walkPath.removeAll()
        distance = 0.0
        duration = 0.0
        calories = 0.0
        averageSpeed = 0.0
        lastLocation = nil
        isTracking = true
        startTime = Date()
        locationManager.startUpdatingLocation()
        print("[WalkTrackingService] 위치 추적 시작!")
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.duration = Date().timeIntervalSince(startTime)
            self.updateAverageSpeed()
        }
    }
    func pauseWalk() {
        print("[WalkTrackingService] pauseWalk() 호출")
        guard isTracking else { return }
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil
        isTracking = false
    }
    func resumeWalk() {
        print("[WalkTrackingService] resumeWalk() 호출")
        guard !isTracking, startTime != nil else { return }
        locationManager.startUpdatingLocation()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.duration = Date().timeIntervalSince(startTime)
            self.updateAverageSpeed()
        }
        isTracking = true
    }
    func endWalk() -> WalkSession? {
        print("[WalkTrackingService] endWalk() 호출")
        guard startTime != nil else { return nil }
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil
        isTracking = false
        let session = WalkSession(
            id: UUID(),
            startTime: startTime!,
            endTime: Date(),
            duration: duration,
            distance: distance,
            calories: calories,
            path: walkPath,
            averageSpeed: averageSpeed
        )
        startTime = nil
        return session
    }
    private func updateAverageSpeed() {
        if duration > 0 {
            averageSpeed = (distance / duration) * 3600 // Convert to km/h
            print("[WalkTrackingService] averageSpeed 갱신: \(averageSpeed)")
        }
    }
    private func updateCalories() {
        calories = distance * caloriesPerKmMultiplier
        print("[WalkTrackingService] calories 갱신: \(calories)")
    }
    
    // MARK: - API Service
    
    /// 산책 세션 데이터를 서버에 업로드
    /// - Parameters:
    ///   - session: 업로드할 산책 세션
    ///   - dogIds: 함께 산책한 강아지 ID 배열
    ///   - completion: 결과 콜백 (성공 또는 실패)
    func uploadWalkSession(session: WalkSession, dogIds: [Int], completion: @escaping (Result<Bool, Error>) -> Void) {
        print("[WalkTrackingService] 산책 세션 업로드 시작: \(session.id)")
        
        // API Base URL
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String, !baseURL.isEmpty else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let urlString = baseURL + "/v1/walks"
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        // 요청 생성
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 요청 데이터 준비
        let sessionData = session.toAPIDictionary(dogIds: dogIds)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: sessionData, options: [])
            request.httpBody = jsonData
            
            // 네트워크 요청 실행
            NetworkManager.shared.performAPIRequest(request) { data, response, error in
                if let error = error {
                    print("[WalkTrackingService] 산책 세션 업로드 실패: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    print("[WalkTrackingService] 산책 세션 업로드 성공: \(session.id)")
                    completion(.success(true))
                } else {
                    if let data = data, let errorString = String(data: data, encoding: .utf8) {
                        print("[WalkTrackingService] 산책 세션 업로드 실패: \(errorString)")
                    }
                    completion(.failure(URLError(.badServerResponse)))
                }
            }
        } catch {
            print("[WalkTrackingService] JSON 인코딩 실패: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension WalkTrackingService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("[WalkTrackingService] didUpdateLocations 호출: \(locations.map { $0.coordinate }) isTracking=\(isTracking)")
        guard let location = locations.last else { return }
        
        // currentLocation은 항상 업데이트
        currentLocation = location
        
        let coord = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        
        // 트래킹 중일 때만 경로 및 거리 업데이트
        if isTracking {
            walkPath.append(coord)
            print("[WalkTrackingService] walkPath에 추가된 좌표: \(coord.lat), \(coord.lng)")
            if let last = lastLocation {
                let dist = location.distance(from: last)
                distance += dist / 1000
                print("[WalkTrackingService] distance 누적: \(distance)")
                updateCalories()
            }
            lastLocation = location
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[WalkTrackingService] Location manager failed with error: \(error)")
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .walkLocationError, object: error)
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("[WalkTrackingService] didChangeAuthorization: \(status.rawValue)")
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location permission denied")
        case .notDetermined:
            requestLocationPermission()
        @unknown default:
            break
        }
    }
}

extension Notification.Name {
    static let walkLocationError = Notification.Name("walkLocationError")
}
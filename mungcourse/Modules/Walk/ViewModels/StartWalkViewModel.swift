import Foundation
import SwiftUI
import NMapsMap
import Combine

class StartWalkViewModel: ObservableObject {
    // Map state
    @Published var centerCoordinate: NMGLatLng
    @Published var zoomLevel: Double = 16.0
    @Published var pathCoordinates: [NMGLatLng] = []
    
    // Walk stats
    @Published var distance: Double = 0.0 // in kilometers
    @Published var duration: TimeInterval = 0.0 // in seconds
    @Published var calories: Double = 0.0 // in kcal
    
    // Walk state
    @Published var isWalking: Bool = false
    @Published var isPaused: Bool = false
    @Published var userLocation: NMGLatLng? = nil

    // Services
    private let walkTrackingService: WalkTrackingService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 권한 안내 및 에러 알림
    @Published var showPermissionAlert: Bool = false
    @Published var showLocationErrorAlert: Bool = false
    @Published var locationErrorMessage: String = ""
    
    private func setupLocationErrorObserver() {
        NotificationCenter.default.addObserver(forName: .walkLocationError, object: nil, queue: .main) { [weak self] notification in
            self?.locationErrorMessage = "위치 서비스에 문제가 발생했습니다.\n앱 설정에서 위치 권한을 확인해주세요."
            self?.showLocationErrorAlert = true
        }
    }
    
    // MARK: - User Actions
    init(walkTrackingService: WalkTrackingService = WalkTrackingService()) {
        self.walkTrackingService = walkTrackingService
        
        // Default to Seoul coordinates if no location is available yet
        self.centerCoordinate = NMGLatLng(lat: 37.5665, lng: 126.9780)
        
        // Subscribe to location updates from the tracking service
        walkTrackingService.$currentLocation
            .sink { [weak self] location in
                guard let self = self else { return }
                if let location = location {
                    let coord = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
                    self.userLocation = coord
                } else {
                    self.userLocation = nil
                }
            }
            .store(in: &cancellables)
        
        // Subscribe to path updates
        walkTrackingService.$walkPath
            .sink { [weak self] path in
                print("[디버그] pathCoordinates 변경: count=\(path.count), 값=\(path)")
                self?.pathCoordinates = path
            }
            .store(in: &cancellables)
        
        // Subscribe to distance updates
        walkTrackingService.$distance
            .sink { [weak self] distance in
                self?.distance = distance
            }
            .store(in: &cancellables)
        
        // Subscribe to duration updates
        walkTrackingService.$duration
            .sink { [weak self] duration in
                self?.duration = duration
            }
            .store(in: &cancellables)
        
        // Subscribe to calories updates
        walkTrackingService.$calories
            .sink { [weak self] calories in
                self?.calories = calories
            }
            .store(in: &cancellables)
        
        // Subscribe to tracking state
        walkTrackingService.$isTracking
            .sink { [weak self] isTracking in
                self?.isWalking = isTracking
                self?.isPaused = !isTracking && self?.duration ?? 0 > 0
            }
            .store(in: &cancellables)
        
        setupLocationErrorObserver()
    }
    
    func startWalk() {
        walkTrackingService.startWalk(onPermissionDenied: { [weak self] in
            self?.showPermissionAlert = true
        })
    }
    
    func pauseWalk() {
        walkTrackingService.pauseWalk()
    }
    
    func resumeWalk() {
        walkTrackingService.resumeWalk()
    }
    
    func endWalk() -> WalkSession? {
        return walkTrackingService.endWalk()
    }
    
    // MARK: - Formatted Outputs
    
    var formattedDistance: String {
        String(format: "%.2f", distance)
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var formattedCalories: String {
        String(format: "%.0f", calories)
    }
    
    // MARK: - API 연동
    func uploadWalkSession(_ session: WalkSession, dogIds: [Int], completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://your.api/v1/walks") else {
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // TODO: 인증 토큰 필요시 헤더 추가
        let body = session.toAPIDictionary(dogIds: dogIds)
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let _ = error {
                completion(false)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(false)
                return
            }
            completion(true)
        }.resume()
    }
}
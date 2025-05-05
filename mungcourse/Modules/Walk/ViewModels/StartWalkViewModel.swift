import Foundation
import SwiftUI
import NMapsMap
import Combine

class StartWalkViewModel: ObservableObject {
    @Published var smokingZones: [NMGLatLng] = []
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
        print("[StartWalkViewModel] init 호출")
        self.walkTrackingService = walkTrackingService
        // Default to Seoul coordinates if no location is available yet
        self.centerCoordinate = NMGLatLng(lat: 37.5665, lng: 126.9780)
        walkTrackingService.$currentLocation
            .sink { [weak self] location in
                print("[StartWalkViewModel] currentLocation 변경: \(String(describing: location))")
                guard let self = self else { return }
                if let location = location {
                    let coord = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
                    print("[StartWalkViewModel] userLocation 갱신: \(coord)")
                    self.userLocation = coord
                } else {
                    print("[StartWalkViewModel] userLocation nil")
                    self.userLocation = nil
                }
            }
            .store(in: &cancellables)
        walkTrackingService.$walkPath
            .sink { [weak self] path in
                print("[StartWalkViewModel] pathCoordinates 변경: count=\(path.count), 값=\(path)")
                self?.pathCoordinates = path
            }
            .store(in: &cancellables)
        walkTrackingService.$distance
            .sink { [weak self] distance in
                print("[StartWalkViewModel] distance 변경: \(distance)")
                self?.distance = distance
            }
            .store(in: &cancellables)
        walkTrackingService.$duration
            .sink { [weak self] duration in
                print("[StartWalkViewModel] duration 변경: \(duration)")
                self?.duration = duration
            }
            .store(in: &cancellables)
        walkTrackingService.$calories
            .sink { [weak self] calories in
                print("[StartWalkViewModel] calories 변경: \(calories)")
                self?.calories = calories
            }
            .store(in: &cancellables)
        walkTrackingService.$isTracking
            .sink { [weak self] isTracking in
                print("[StartWalkViewModel] isTracking 변경: \(isTracking)")
                self?.isWalking = isTracking
                self?.isPaused = !isTracking && self?.duration ?? 0 > 0
            }
            .store(in: &cancellables)
        setupLocationErrorObserver()
    }
    
    func startWalk() {
        // 산책 시작 위치 기준 흡연구역 조회
        if let startLocation = userLocation {
            fetchSmokingZones(center: startLocation)
        }

        print("[StartWalkViewModel] startWalk() 호출")
        walkTrackingService.startWalk(onPermissionDenied: { [weak self] in
            print("[StartWalkViewModel] 위치 권한 거부됨")
            self?.showPermissionAlert = true
        })
    }
    func pauseWalk() {
        print("[StartWalkViewModel] pauseWalk() 호출")
        walkTrackingService.pauseWalk()
    }
    func resumeWalk() {
        print("[StartWalkViewModel] resumeWalk() 호출")
        walkTrackingService.resumeWalk()
    }
    func endWalk() -> WalkSession? {
        print("[StartWalkViewModel] endWalk() 호출")
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
    private static var apiBaseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? ""
    }
    
    func uploadWalkSession(_ session: WalkSession, dogIds: [Int], completion: @escaping (Bool) -> Void) {
        print("📤 산책 데이터 업로드 시작")
        
        WalkService.shared.uploadWalkSession(session, dogIds: dogIds)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionResult in
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    print("❌ 산책 데이터 업로드 실패: \(error)")
                    completion(false)
                }
            }, receiveValue: { success in
                if success {
                    print("✅ 산책 데이터 업로드 성공")
                    completion(true)
                } else {
                    print("⚠️ 산책 데이터 업로드 실패")
                    completion(false)
                }
            })
            .store(in: &cancellables)
    }
}
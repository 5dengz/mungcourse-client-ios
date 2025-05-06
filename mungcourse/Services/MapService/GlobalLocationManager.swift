import Foundation
import CoreLocation

class GlobalLocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    static let shared = GlobalLocationManager()
    private let locationManager = CLLocationManager()
    @Published var lastLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    // 초기화 완료 여부를 추적하는 프로퍼티 추가
    private var isInitialized: Bool = false

    private override init() {
        super.init()
        print("🌍 [GlobalLocationManager] 초기화 시작")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5 // 5m 이동마다 업데이트
        
        // 초기 권한 상태 저장
        authorizationStatus = locationManager.authorizationStatus
        print("🌍 [GlobalLocationManager] 초기 권한 상태: \(authorizationStatus.rawValue)")
        
        // 앱이 시작될 때 바로 위치 권한 요청 및 업데이트 시작
        requestLocationPermissionIfNeeded()
        
        print("🌍 [GlobalLocationManager] 초기화 완료")
    }
    
    // 위치 권한 요청 메서드 추가
    func requestLocationPermissionIfNeeded() {
        let status = locationManager.authorizationStatus
        print("🌍 [GlobalLocationManager] 권한 요청/확인: 현재 상태 = \(status.rawValue)")
        
        if status == .notDetermined {
            print("🌍 [GlobalLocationManager] 위치 권한 요청 중")
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            print("🌍 [GlobalLocationManager] 이미 위치 권한 있음, 위치 업데이트 시작")
            startUpdatingLocation()
        } else {
            print("🚫 [GlobalLocationManager] 위치 권한 거부됨 (denied/restricted)")
        }
    }

    func startUpdatingLocation() {
        if CLLocationManager.locationServicesEnabled() {
            // 권한 상태가 허용된 경우에만 위치 업데이트 시작
            let status = locationManager.authorizationStatus
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                print("🌍 [GlobalLocationManager] startUpdatingLocation() called at \(Date()) - 권한 허용됨")
                locationManager.startUpdatingLocation()
                
                // 위치가 바로 업데이트 되지 않을 수 있으므로, 마지막 알려진 위치가 있다면 사용
                if let cachedLocation = locationManager.location {
                    print("📍 [GlobalLocationManager] 캐시된 위치 사용: lat=\(cachedLocation.coordinate.latitude), lng=\(cachedLocation.coordinate.longitude)")
                    lastLocation = cachedLocation
                }
            } else {
                print("🚫 [GlobalLocationManager] 위치 권한이 허용되지 않음: \(status)")
                locationManager.requestWhenInUseAuthorization()
            }
        } else {
            print("🚫 [GlobalLocationManager] 위치 서비스가 비활성화됨")
        }
    }

    func stopUpdatingLocation() {
        print("🌍 [GlobalLocationManager] stopUpdatingLocation() called at \(Date())")
        locationManager.stopUpdatingLocation()
    }

    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("📍 [GlobalLocationManager] didUpdateLocations called at \(Date())")
        print("📍 [GlobalLocationManager] 받은 위치 개수: \(locations.count)")
        
        if let location = locations.last {
            print("📍 [GlobalLocationManager] 위치 업데이트: lat=\(location.coordinate.latitude), lng=\(location.coordinate.longitude), accuracy=\(location.horizontalAccuracy)m")
            lastLocation = location
            
            // 정확도가 좋지 않으면 로그 표시
            if location.horizontalAccuracy > 100 {
                print("⚠️ [GlobalLocationManager] 위치 정확도가 낮음: \(location.horizontalAccuracy)m")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ [GlobalLocationManager] 위치 업데이트 실패: \(error.localizedDescription)")
        
        // 특정 오류에 대한 자세한 정보 제공
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                print("❌ [GlobalLocationManager] 위치 권한 거부됨")
            case .network:
                print("❌ [GlobalLocationManager] 네트워크 관련 오류")
            case .locationUnknown:
                print("❌ [GlobalLocationManager] 위치를 결정할 수 없음")
            default:
                print("❌ [GlobalLocationManager] 기타 위치 오류: \(clError.code)")
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let oldStatus = authorizationStatus
        authorizationStatus = manager.authorizationStatus
        print("🔒 [GlobalLocationManager] 권한 상태 변경: \(oldStatus.rawValue) -> \(authorizationStatus.rawValue)")
        
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            print("✅ [GlobalLocationManager] 위치 권한 허용됨, 위치 업데이트 시작")
            startUpdatingLocation()
        } else {
            print("🚫 [GlobalLocationManager] 위치 권한 거부됨")
        }
    }
}

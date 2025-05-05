import Foundation
import CoreLocation

class GlobalLocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    static let shared = GlobalLocationManager()
    private let locationManager = CLLocationManager()
    @Published var lastLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5 // 5m 이동마다 업데이트
    }

    func startUpdatingLocation() {
        if CLLocationManager.locationServicesEnabled() {
            // 권한 상태가 허용된 경우에만 위치 업데이트 시작
            let status = locationManager.authorizationStatus
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                print("[GlobalLocationManager] startUpdatingLocation() called at \(Date()) - 권한 허용됨")
                locationManager.startUpdatingLocation()
            } else {
                print("[GlobalLocationManager] 위치 권한이 허용되지 않음: \(status)")
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("[GlobalLocationManager] didUpdateLocations called at \(Date()) with locations: \(locations)")
        if let location = locations.last {
            lastLocation = location
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}

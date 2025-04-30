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
            print("[GlobalLocationManager] startUpdatingLocation() called at \(Date())")
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
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

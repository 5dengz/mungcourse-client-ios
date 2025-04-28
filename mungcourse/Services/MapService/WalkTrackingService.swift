import Foundation
import CoreLocation
import NMapsMap
import Combine

/// Service responsible for tracking walk sessions, including location updates, distance calculations, and session management
class WalkTrackingService: NSObject, ObservableObject {
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
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5 // meters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        requestLocationPermission()
    }
    
    private func requestLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: - Walk Session Management
    func startWalk(onPermissionDenied: (() -> Void)? = nil) {
        guard !isTracking else { return }
        let status = locationManager.authorizationStatus
        print("[WalkTrackingService] startWalk() called, 권한 상태: \(status.rawValue)")
        guard status == .authorizedAlways || status == .authorizedWhenInUse else {
            print("[WalkTrackingService] 위치 권한이 없습니다. 안내 필요.")
            onPermissionDenied?()
            return
        }
        
        // Clear previous data
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
        guard isTracking else { return }
        
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil
        isTracking = false
    }
    
    func resumeWalk() {
        guard !isTracking, startTime != nil else { return }
        
        locationManager.startUpdatingLocation()
        
        // Resume timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.duration = Date().timeIntervalSince(startTime)
            self.updateAverageSpeed()
        }
        
        isTracking = true
    }
    
    func endWalk() -> WalkSession? {
        guard startTime != nil else { return nil }
        
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil
        isTracking = false
        
        // Create a session record
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
        
        // Reset tracking state
        startTime = nil
        
        return session
    }
    
    // MARK: - Helper Methods
    private func updateAverageSpeed() {
        if duration > 0 {
            averageSpeed = (distance / duration) * 3600 // Convert to km/h
        }
    }
    
    private func updateCalories() {
        calories = distance * caloriesPerKmMultiplier
    }
}

// MARK: - CLLocationManagerDelegate
extension WalkTrackingService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, isTracking else { return }
        
        currentLocation = location
        
        // Add to path
        let coord = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        walkPath.append(coord)
        
        // Update distance if we have a previous location
        if let lastLocation = lastLocation {
            let distanceInMeters = location.distance(from: lastLocation)
            distance += distanceInMeters / 1000 // Convert to kilometers
            updateCalories() // Update calories based on new distance
        }
        
        lastLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[WalkTrackingService] Location manager failed with error: \(error)")
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .walkLocationError, object: error)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
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
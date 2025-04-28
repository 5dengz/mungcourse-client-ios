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
    }
    
    // MARK: - User Actions
    
    func startWalk() {
        walkTrackingService.startWalk()
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
}
import SwiftUI
import NMapsMap

/// A SwiftUI wrapper for Naver Maps NMFMapView
struct NaverMapView: UIViewRepresentable {
    // Map state bindings
    @Binding var centerCoordinate: NMGLatLng
    @Binding var zoomLevel: Double
    @Binding var pathCoordinates: [NMGLatLng]
    
    // Callbacks
    var onMapTapped: ((NMGLatLng) -> Void)?
    var onUserLocationUpdated: ((NMGLatLng) -> Void)?
    
    // Configuration options
    var showUserLocation: Bool = true
    var trackingMode: NMFMyPositionMode = .direction
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        let mapView = NMFNaverMapView()
        
        // Configure map
        mapView.showLocationButton = true
        mapView.showZoomControls = true
        mapView.showCompass = true
        mapView.showScaleBar = true
        
        // Set delegate
        mapView.mapView.touchDelegate = context.coordinator
        mapView.mapView.addCameraDelegate(context.coordinator)
        
        // Configure user location tracking
        if showUserLocation {
            mapView.mapView.positionMode = trackingMode
            mapView.mapView.locationOverlay.hidden = false
        } else {
            mapView.mapView.positionMode = .disabled
            mapView.mapView.locationOverlay.hidden = true
        }
        
        // Set initial camera position
        let cameraUpdate = NMFCameraUpdate(scrollTo: centerCoordinate, zoomTo: zoomLevel)
        mapView.mapView.moveCamera(cameraUpdate)
        
        // Add path overlay if needed
        if !pathCoordinates.isEmpty {
            updatePathOverlay(mapView: mapView.mapView, coordinates: pathCoordinates)
        }
        
        return mapView
    }

    func updateUIView(_ mapView: NMFNaverMapView, context: Context) {
        // Update camera position if needed
        if mapView.mapView.cameraPosition.target != centerCoordinate {
            let cameraUpdate = NMFCameraUpdate(scrollTo: centerCoordinate)
            cameraUpdate.animation = .easeIn
            mapView.mapView.moveCamera(cameraUpdate)
        }
        
        // Update zoom level if needed
        if mapView.mapView.cameraPosition.zoom != zoomLevel {
            let cameraUpdate = NMFCameraUpdate(zoomTo: zoomLevel)
            cameraUpdate.animation = .easeIn
            mapView.mapView.moveCamera(cameraUpdate)
        }
        
        // Update tracking mode if needed
        if showUserLocation {
            mapView.mapView.positionMode = trackingMode
            mapView.mapView.locationOverlay.hidden = false
        } else {
            mapView.mapView.positionMode = .disabled
            mapView.mapView.locationOverlay.hidden = true
        }
        
        // Update path overlay
        updatePathOverlay(mapView: mapView.mapView, coordinates: pathCoordinates)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Helper method to update the path overlay
    private func updatePathOverlay(mapView: NMFMapView, coordinates: [NMGLatLng]) {
        // Remove existing overlays
        mapView.overlays.forEach { overlay in
            if let pathOverlay = overlay as? NMFPath {
                pathOverlay.mapView = nil
            }
        }
        
        // Add new path overlay if we have coordinates
        if coordinates.count >= 2 {
            let path = NMFPath()
            path.path = NMGLineString(points: coordinates)
            path.color = UIColor(red: 0.28, green: 0.81, blue: 0.43, alpha: 1.0) // #48CF6E
            path.width = 5
            path.outlineWidth = 1
            path.mapView = mapView
        }
    }
    
    // Coordinator to handle map interactions
    class Coordinator: NSObject, NMFMapViewTouchDelegate, NMFMapViewCameraDelegate {
        var parent: NaverMapView
        
        init(_ parent: NaverMapView) {
            self.parent = parent
        }
        
        // Handle map taps
        func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
            parent.onMapTapped?(latlng)
        }
        
        // Handle camera changes
        func mapViewCameraIdle(_ mapView: NMFMapView) {
            parent.centerCoordinate = mapView.cameraPosition.target
            parent.zoomLevel = mapView.cameraPosition.zoom
        }
    }
}
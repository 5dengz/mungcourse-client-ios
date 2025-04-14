import SwiftUI
import NMapsMap

struct NaverMapView: UIViewRepresentable {
    @Binding var centerCoordinate: NMGLatLng
    @Binding var zoomLevel: Double
    @Binding var pathCoordinates: [NMGLatLng]
    
    var onMapTapped: ((NMGLatLng) -> Void)?
    var onUserLocationUpdated: ((NMGLatLng) -> Void)?
    
    var showUserLocation: Bool = true
    var trackingMode: NMFMyPositionMode = .direction
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        let mapView = NMFNaverMapView()
        
        mapView.showLocationButton = true
        mapView.showZoomControls = true
        mapView.showCompass = true
        mapView.showScaleBar = true
        
        mapView.mapView.touchDelegate = context.coordinator
        mapView.mapView.addCameraDelegate(delegate: context.coordinator)
        
        if showUserLocation {
            mapView.mapView.positionMode = trackingMode
            mapView.mapView.locationOverlay.hidden = false
        } else {
            mapView.mapView.positionMode = .disabled
            mapView.mapView.locationOverlay.hidden = true
        }
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: centerCoordinate, zoomTo: zoomLevel)
        mapView.mapView.moveCamera(cameraUpdate)
        
        // Use coordinator to manage the path overlay.
        context.coordinator.updatePathOverlay(mapView: mapView.mapView, coordinates: pathCoordinates)
        
        return mapView
    }
    
    func updateUIView(_ mapView: NMFNaverMapView, context: Context) {
        if mapView.mapView.cameraPosition.target != centerCoordinate {
            let cameraUpdate = NMFCameraUpdate(scrollTo: centerCoordinate)
            cameraUpdate.animation = .easeIn
            mapView.mapView.moveCamera(cameraUpdate)
        }
        
        if mapView.mapView.cameraPosition.zoom != zoomLevel {
            let cameraUpdate = NMFCameraUpdate(zoomTo: zoomLevel)
            cameraUpdate.animation = .easeIn
            mapView.mapView.moveCamera(cameraUpdate)
        }
        
        if showUserLocation {
            mapView.mapView.positionMode = trackingMode
            mapView.mapView.locationOverlay.hidden = false
        } else {
            mapView.mapView.positionMode = .disabled
            mapView.mapView.locationOverlay.hidden = true
        }
        
        // Update the path overlay using the coordinator.
        context.coordinator.updatePathOverlay(mapView: mapView.mapView, coordinates: pathCoordinates)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NMFMapViewTouchDelegate, NMFMapViewCameraDelegate {
        var parent: NaverMapView
        // Store the current path overlay.
        var pathOverlay: NMFPath?
        
        init(_ parent: NaverMapView) {
            self.parent = parent
        }
        
        // Update or add a new path overlay.
        func updatePathOverlay(mapView: NMFMapView, coordinates: [NMGLatLng]) {
            // Remove existing overlay if present.
            if let existingPath = pathOverlay {
                existingPath.mapView = nil
                pathOverlay = nil
            }
            
            // Add new path overlay if we have enough coordinates.
            if coordinates.count >= 2 {
                let newPath = NMFPath()
                newPath.path = NMGLineString(points: coordinates)
                newPath.color = UIColor(red: 0.28, green: 0.81, blue: 0.43, alpha: 1.0)
                newPath.width = 5
                newPath.outlineWidth = 1
                newPath.mapView = mapView
                pathOverlay = newPath
            }
        }
        
        func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
            parent.onMapTapped?(latlng)
        }
        
        func mapViewCameraIdle(_ mapView: NMFMapView) {
            parent.centerCoordinate = mapView.cameraPosition.target
            parent.zoomLevel = mapView.cameraPosition.zoom
        }
    }
}

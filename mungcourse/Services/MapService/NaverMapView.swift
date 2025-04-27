import SwiftUI
import NMapsMap
import QuartzCore

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
        
        // 기본 위치 오버레이 숨기기
        mapView.mapView.positionMode = .disabled
        mapView.mapView.locationOverlay.hidden = true
        
        // 커스텀 발바닥 마커 생성
        let paw = NMFMarker()
        if let pawImage = UIImage(named: "pinpoint_paw") {
            paw.iconImage = NMFOverlayImage(image: pawImage)
        }
        paw.width = 25
        paw.height = 32
        paw.anchor = CGPoint(x: 0.5, y: 1.0)
        paw.position = centerCoordinate
        paw.mapView = mapView.mapView
        context.coordinator.pawMarker = paw
        
        // 커스텀 이펙트 뷰 생성 및 애니메이션
        let effectView = UIImageView(image: UIImage(named: "pinpoint_effect"))
        effectView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let point = mapView.mapView.projection.point(from: centerCoordinate)
        effectView.center = point
        mapView.addSubview(effectView)
        context.coordinator.effectView = effectView
        let pulseAnim = CABasicAnimation(keyPath: "transform.scale")
        pulseAnim.fromValue = 0.5
        pulseAnim.toValue = 2.0
        pulseAnim.duration = 1.0
        pulseAnim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        pulseAnim.repeatCount = Float.infinity
        effectView.layer.add(pulseAnim, forKey: "pulse")
        
        // 카메라 이동
        let cameraUpdate = NMFCameraUpdate(scrollTo: centerCoordinate, zoomTo: zoomLevel)
        mapView.mapView.moveCamera(cameraUpdate)
        
        // 경로 오버레이 업데이트
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
        
        // 기본 My-LocationOverlay 숨김 및 마커 위치 업데이트
        mapView.mapView.positionMode = .disabled
        mapView.mapView.locationOverlay.hidden = true
        context.coordinator.pawMarker?.position = centerCoordinate
        if let effectView = context.coordinator.effectView {
            let point = mapView.mapView.projection.point(from: centerCoordinate)
            effectView.center = point
        }
        
        // 경로 오버레이 업데이트
        context.coordinator.updatePathOverlay(mapView: mapView.mapView, coordinates: pathCoordinates)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NMFMapViewTouchDelegate, NMFMapViewCameraDelegate {
        var parent: NaverMapView
        var pathOverlay: NMFPath?
        var pawMarker: NMFMarker?
        var effectView: UIImageView?
        
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

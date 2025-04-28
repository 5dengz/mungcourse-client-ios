import SwiftUI
import NMapsMap
import QuartzCore

struct NaverMapView: UIViewRepresentable {
    @Binding var centerCoordinate: NMGLatLng
    @Binding var zoomLevel: Double
    @Binding var pathCoordinates: [NMGLatLng]
    @Binding var userLocation: NMGLatLng?
    
    var onMapTapped: ((NMGLatLng) -> Void)?
    var onUserLocationUpdated: ((NMGLatLng) -> Void)?
    
    var showUserLocation: Bool = true
    var trackingMode: NMFMyPositionMode = .direction
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        print("[디버그] makeUIView 호출")
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
        let pawImage = UIImage(named: "pinpoint_paw")
        if pawImage == nil {
            print("[디버그] pinpoint_paw 이미지를 불러오지 못했습니다.")
        } else {
            print("[디버그] pinpoint_paw 이미지 정상 로드됨")
        }
        let paw = NMFMarker()
        if let pawImage = pawImage {
            paw.iconImage = NMFOverlayImage(image: pawImage)
        }
        paw.width = 25
        paw.height = 32
        paw.anchor = CGPoint(x: 0.5, y: 1.0)
        if let userLocation = userLocation {
            paw.position = userLocation
        }
        paw.mapView = mapView.mapView
        context.coordinator.pawMarker = paw
        // 커스텀 이펙트 뷰 생성 및 애니메이션
        let effectView = UIImageView(image: UIImage(named: "pinpoint_effect"))
        effectView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        if let userLocation = userLocation {
            let point = mapView.mapView.projection.point(from: userLocation)
            effectView.center = point
        }
        // effectView가 pawMarker보다 먼저 addSubview되어야 z순서가 아래로 감
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
        print("[디버그] makeUIView - centerCoordinate: \(centerCoordinate), zoomLevel: \(zoomLevel)")
        print("[디버그] makeUIView - pathCoordinates: count=\(pathCoordinates.count), 값=\(pathCoordinates)")
        if pathCoordinates.count >= 2 {
            DispatchQueue.main.async {
                context.coordinator.updatePathOverlay(mapView: mapView.mapView, coordinates: pathCoordinates)
            }
        } else {
            print("[디버그] makeUIView - Polyline 생략: 좌표가 2개 미만임")
        }
        return mapView
    }

    func updateUIView(_ mapView: NMFNaverMapView, context: Context) {
        print("[디버그] updateUIView 호출")
        print("[디버그] updateUIView - centerCoordinate: \(centerCoordinate), zoomLevel: \(zoomLevel)")
        print("[디버그] updateUIView - pathCoordinates: count=\(pathCoordinates.count), 값=\(pathCoordinates)")
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
        // 마커와 이펙트 위치를 userLocation 기준으로 업데이트
        if let userLocation = userLocation {
            context.coordinator.pawMarker?.position = userLocation
            if let effectView = context.coordinator.effectView {
                let point = mapView.mapView.projection.point(from: userLocation)
                effectView.center = point
            }
        }
        // 경로 오버레이 업데이트 (방어 코드 추가)
        print("[디버그] pathCoordinates 변경됨: count=\(pathCoordinates.count)")
        DispatchQueue.main.async {
            context.coordinator.updatePathOverlay(mapView: mapView.mapView, coordinates: pathCoordinates)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NMFMapViewTouchDelegate, NMFMapViewCameraDelegate {
        let parent: NaverMapView
        weak var pathOverlay: NMFPath?
        var pawMarker: NMFMarker?
        var effectView: UIImageView?
        
        init(_ parent: NaverMapView) {
            self.parent = parent
        }
        
        // Update or add a new path overlay.
        func updatePathOverlay(mapView: NMFMapView, coordinates: [NMGLatLng]) {
            print("[디버그] updatePathOverlay 호출 - coordinates: count=\(coordinates.count), 값=\(coordinates)")
            // 좌표 유효성 검사
            for (i, coord) in coordinates.enumerated() {
                guard abs(coord.lat) <= 90, abs(coord.lng) <= 180 else {
                    print("[Error] Invalid coordinate at index \(i): \(coord)")
                    return
                }
            }
            // 기존 오버레이 완전 제거
            if let existingPath = pathOverlay {
                print("[디버그] 기존 pathOverlay 제거")
                existingPath.mapView = nil
                pathOverlay = nil
            }
            // 2개 미만 좌표면 오버레이 생성하지 않음
            guard coordinates.count >= 2 else {
                print("[디버그] Polyline 생략: 좌표가 2개 미만임")
                return
            }
            print("[디버그] NMFPath 생성 및 NMGLineString 할당 시도")
            let newPath = NMFPath()
            newPath.path = NMGLineString(points: coordinates)
            newPath.color = UIColor(red: 0.28, green: 0.81, blue: 0.43, alpha: 1.0)
            newPath.width = 5
            newPath.outlineWidth = 1
            newPath.mapView = mapView
            pathOverlay = newPath
            print("[디버그] Polyline 정상 생성 및 지도에 추가 완료")
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

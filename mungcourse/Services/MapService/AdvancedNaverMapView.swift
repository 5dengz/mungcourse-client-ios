import SwiftUI
import NMapsMap
import QuartzCore

struct AdvancedNaverMapView: UIViewRepresentable {
    @Binding var dangerCoordinates: [NMGLatLng]
    var dogPlaceCoordinates: [NMGLatLng] = []
    private var dangerMarkers: [NMFMarker] = []
    private var dogPlaceMarkers: [NMFMarker] = []
    @Binding var centerCoordinate: NMGLatLng
    @Binding var zoomLevel: Double
    @Binding var pathCoordinates: [NMGLatLng]
    @Binding var userLocation: NMGLatLng?
    
    var onMapTapped: ((NMGLatLng) -> Void)?
    var onUserLocationUpdated: ((NMGLatLng) -> Void)?
    
    var showUserLocation: Bool = true
    var trackingMode: NMFMyPositionMode = .direction
    
    // 명시적인 public initializer 추가
    init(dangerCoordinates: Binding<[NMGLatLng]>,
         dogPlaceCoordinates: [NMGLatLng] = [],
         centerCoordinate: Binding<NMGLatLng>,
         zoomLevel: Binding<Double>,
         pathCoordinates: Binding<[NMGLatLng]>,
         userLocation: Binding<NMGLatLng?>,
         onMapTapped: ((NMGLatLng) -> Void)? = nil,
         onUserLocationUpdated: ((NMGLatLng) -> Void)? = nil,
         showUserLocation: Bool = true,
         trackingMode: NMFMyPositionMode = .direction) {
        self._dangerCoordinates = dangerCoordinates
        self.dogPlaceCoordinates = dogPlaceCoordinates
        self._centerCoordinate = centerCoordinate
        self._zoomLevel = zoomLevel
        self._pathCoordinates = pathCoordinates
        self._userLocation = userLocation
        self.onMapTapped = onMapTapped
        self.onUserLocationUpdated = onUserLocationUpdated
        self.showUserLocation = showUserLocation
        self.trackingMode = trackingMode
    }
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        print("[디버그] makeUIView 호출")
        
        // 먼저 mapView를 생성
        let mapView = NMFNaverMapView()
        
        mapView.showLocationButton = showUserLocation
        mapView.mapView.positionMode = trackingMode
        mapView.showZoomControls = true
        mapView.showCompass = true
        mapView.showScaleBar = true
        
        // danger 마커 표시 (mapView 선언 이후로 이동)
        for coord in dangerCoordinates {
            let marker = NMFMarker(position: coord)
            marker.iconImage = NMFOverlayImage(name: "pinpoint_danger")
            marker.width = 25
            marker.height = 32
            marker.zIndex = 100
            marker.mapView = mapView.mapView
            context.coordinator.dangerMarkers.append(marker)
        }
        // dogPlaces 마커 표시
        for coord in dogPlaceCoordinates {
            let marker = NMFMarker(position: coord)
            marker.iconImage = NMFOverlayImage(name: "pinpoint_paw")
            marker.width = 31
            marker.height = 39
            marker.zIndex = 99
            marker.mapView = mapView.mapView
            context.coordinator.dogPlaceMarkers.append(marker)
        }
        
        // 현위치 버튼 위치 조정(상단 우측, 여백 80, 16)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let buttons = mapView.subviews.compactMap { $0 as? UIButton }
            print("[디버그] NaverMapView 내 버튼 개수: \(buttons.count)")
            for btn in buttons {
                let label = btn.accessibilityLabel ?? "nil"
                let id = btn.accessibilityIdentifier ?? "nil"
                print("[디버그] 버튼 label: \(label), id: \(id)")
            }
            if let locationButton = buttons.first(where: { $0.accessibilityLabel == "내 위치" || $0.accessibilityIdentifier == "NMFLocationButton" }) {
                print("[디버그] 현위치 버튼 발견! 위치 조정 시도")
                locationButton.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.deactivate(locationButton.constraints)
                NSLayoutConstraint.activate([
                    locationButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 10),
                    locationButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16)
                ])
            } else {
                print("[디버그] 현위치 버튼을 찾지 못함")
            }
        }
        
        mapView.mapView.touchDelegate = context.coordinator
        mapView.mapView.addCameraDelegate(delegate: context.coordinator)
        
        // 이펙트 마커 생성 (발바닥 마커 아래에 위치하도록 먼저 생성)
        let effectImage = UIImage(named: "pinpoint_effect")
        if effectImage == nil {
            print("[디버그] pinpoint_effect 이미지를 불러오지 못했습니다.")
        } else {
            print("[디버그] pinpoint_effect 이미지 정상 로드됨")
        }
        
        let effect = NMFMarker()
        if let effectImage = effectImage {
            effect.iconImage = NMFOverlayImage(image: effectImage)
        }
        effect.width = 30
        effect.height = 14
        effect.anchor = CGPoint(x: 0.5, y: 0.5)
        effect.zIndex = 0 // 낮은 zIndex로 설정하여 발바닥 마커 아래에 표시
        if let userLocation = userLocation {
            effect.position = userLocation
        }
        effect.mapView = mapView.mapView
        context.coordinator.effectMarker = effect
        
        // 펄스 애니메이션을 위한 타이머 설정 (원본 이미지 비율 30x14 유지)
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak effect] timer in
            guard let effect = effect else {
                timer.invalidate()
                return
            }
            
            let scale = 0.8 + 0.5 * sin(Date.timeIntervalSinceReferenceDate)
            effect.width = 30 * scale
            effect.height = 14 * scale
        }
        
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
        paw.zIndex = 1 // 높은 zIndex로 설정하여 이펙트 마커 위에 표시
        if let userLocation = userLocation {
            paw.position = userLocation
        }
        paw.mapView = mapView.mapView
        context.coordinator.pawMarker = paw
        
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
        // danger 마커 업데이트
        // 기존 dangerMarkers 제거
        for marker in context.coordinator.dangerMarkers {
            marker.mapView = nil
        }
        context.coordinator.dangerMarkers.removeAll()
        // 기존 dogPlaces 마커 제거
        for marker in context.coordinator.dogPlaceMarkers {
            marker.mapView = nil
        }
        context.coordinator.dogPlaceMarkers.removeAll()
        // danger 마커 다시 추가
        for coord in self.dangerCoordinates {
            let marker = NMFMarker(position: coord)
            marker.iconImage = NMFOverlayImage(name: "pinpoint_danger")
            marker.width = 25
            marker.height = 32
            marker.zIndex = 100
            marker.mapView = mapView.mapView
            context.coordinator.dangerMarkers.append(marker)
        }
        // dogPlaces 마커 다시 추가
        for coord in self.dogPlaceCoordinates {
            let marker = NMFMarker(position: coord)
            marker.iconImage = NMFOverlayImage(name: "pinpoint_paw")
            marker.width = 31
            marker.height = 39
            marker.zIndex = 99
            marker.mapView = mapView.mapView
            context.coordinator.dogPlaceMarkers.append(marker)
        }
        // dangerCoordinates 기준 danger 마커 다시 추가
        for coord in dangerCoordinates {
            let marker = NMFMarker(position: coord)
            marker.iconImage = NMFOverlayImage(name: "pinpoint_danger")
            marker.width = 32
            marker.height = 32
            marker.zIndex = 100
            marker.mapView = mapView.mapView
            context.coordinator.dangerMarkers.append(marker)
        }
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
        mapView.mapView.positionMode = trackingMode
        mapView.mapView.locationOverlay.hidden = true // positionMode 설정 후 반드시 숨김 처리
        // 마커와 이펙트 위치를 userLocation 기준으로 업데이트
        if let userLocation = userLocation {
            context.coordinator.pawMarker?.position = userLocation
            context.coordinator.effectMarker?.position = userLocation
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
        var dangerMarkers: [NMFMarker] = []
        var dogPlaceMarkers: [NMFMarker] = []
        let parent: AdvancedNaverMapView
        weak var pathOverlay: NMFPath?
        var pawMarker: NMFMarker?
        var effectMarker: NMFMarker?
        
        init(_ parent: AdvancedNaverMapView) {
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

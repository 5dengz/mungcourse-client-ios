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
    var trackingMode: NMFMyPositionMode = .direction // 기본값: 위치 추적 활성화(NMFMyPositionDirection)
    
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
        print("🗺️ [AdvancedNaverMapView] 초기화: danger=\(dangerCoordinates.wrappedValue.count)개, dogPlace=\(dogPlaceCoordinates.count)개")
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
        print("🗺️ [AdvancedNaverMapView] makeUIView 호출")
        print("🗺️ [AdvancedNaverMapView] dangerCoordinates: \(dangerCoordinates.count)개")
        print("🗺️ [AdvancedNaverMapView] dogPlaceCoordinates: \(dogPlaceCoordinates.count)개")
        
        // 먼저 mapView를 생성
        let mapView = NMFNaverMapView()
        
        mapView.showLocationButton = showUserLocation
        mapView.mapView.positionMode = trackingMode
        mapView.showZoomControls = true
        mapView.showCompass = true
        mapView.showScaleBar = true
        
        // danger 마커 표시 (mapView 선언 이후로 이동)
        print("🗺️ [AdvancedNaverMapView] danger 마커 생성 시작...")
        for (index, coord) in dangerCoordinates.enumerated() {
            print("🗺️ [AdvancedNaverMapView] danger 마커 #\(index): (\(coord.lat), \(coord.lng))")
            let marker = NMFMarker(position: coord)
            marker.iconImage = NMFOverlayImage(name: "pinpoint_danger")
            marker.width = 25
            marker.height = 32
            marker.zIndex = 100
            marker.mapView = mapView.mapView
            context.coordinator.dangerMarkers.append(marker)
        }
        
        // dogPlaces 마커 표시
        print("🗺️ [AdvancedNaverMapView] dogPlace 마커 생성 시작...")
        for (index, coord) in dogPlaceCoordinates.enumerated() {
            print("🗺️ [AdvancedNaverMapView] dogPlace 마커 #\(index): (\(coord.lat), \(coord.lng))")
            let marker = NMFMarker(position: coord)
            marker.iconImage = NMFOverlayImage(name: "pinpoint_paw")
            marker.width = 25
            marker.height = 32
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
        
        // effect 및 paw 마커는 updateUIView에서 생성 및 업데이트합니다.

        // 카메라 이동
        let cameraUpdate = NMFCameraUpdate(scrollTo: centerCoordinate, zoomTo: zoomLevel)
        mapView.mapView.moveCamera(cameraUpdate)
        print("🗺️ [AdvancedNaverMapView] 초기 카메라 이동: center=(\(centerCoordinate.lat), \(centerCoordinate.lng)), zoom=\(zoomLevel)")
        
        // 경로 오버레이 업데이트
        print("🗺️ [AdvancedNaverMapView] makeUIView - pathCoordinates: count=\(pathCoordinates.count)")
        if pathCoordinates.count >= 2 {
            DispatchQueue.main.async {
                context.coordinator.updatePathOverlay(mapView: mapView.mapView, coordinates: pathCoordinates)
            }
        } else {
            print("🗺️ [AdvancedNaverMapView] makeUIView - Polyline 생략: 좌표가 2개 미만임")
        }
        
        print("🗺️ [AdvancedNaverMapView] makeUIView 완료, 마커 개수: danger=\(context.coordinator.dangerMarkers.count), dogPlace=\(context.coordinator.dogPlaceMarkers.count)")
        return mapView
    }

    func updateUIView(_ mapView: NMFNaverMapView, context: Context) {
        print("🗺️ [AdvancedNaverMapView] updateUIView 호출")
        print("🗺️ [AdvancedNaverMapView] 현재 dangerCoordinates: \(dangerCoordinates.count)개")
        print("🗺️ [AdvancedNaverMapView] 현재 dogPlaceCoordinates: \(dogPlaceCoordinates.count)개")
        print("🗺️ [AdvancedNaverMapView] 기존 마커: danger=\(context.coordinator.dangerMarkers.count)개, dogPlace=\(context.coordinator.dogPlaceMarkers.count)개")
        
        // danger 마커 업데이트
        // 기존 dangerMarkers 제거
        for marker in context.coordinator.dangerMarkers {
            marker.mapView = nil
        }
        context.coordinator.dangerMarkers.removeAll()
        print("🗺️ [AdvancedNaverMapView] 기존 danger 마커 제거 완료")
        
        // 기존 dogPlaces 마커 제거
        for marker in context.coordinator.dogPlaceMarkers {
            marker.mapView = nil
        }
        context.coordinator.dogPlaceMarkers.removeAll()
        print("🗺️ [AdvancedNaverMapView] 기존 dogPlace 마커 제거 완료")
        
        // danger 마커 다시 추가
        print("🗺️ [AdvancedNaverMapView] danger 마커 다시 추가 시작...")
        for (index, coord) in self.dangerCoordinates.enumerated() {
            print("🗺️ [AdvancedNaverMapView] danger 마커 #\(index): (\(coord.lat), \(coord.lng))")
            let marker = NMFMarker(position: coord)
            marker.iconImage = NMFOverlayImage(name: "pinpoint_danger")
            marker.width = 25
            marker.height = 32
            marker.zIndex = 100
            marker.mapView = mapView.mapView
            context.coordinator.dangerMarkers.append(marker)
        }
        print("🗺️ [AdvancedNaverMapView] danger 마커 다시 추가 완료: \(context.coordinator.dangerMarkers.count)개")
        
        // dogPlaces 마커 다시 추가
        print("🗺️ [AdvancedNaverMapView] dogPlace 마커 다시 추가 시작...")
        for (index, coord) in self.dogPlaceCoordinates.enumerated() {
            print("🗺️ [AdvancedNaverMapView] dogPlace 마커 #\(index): (\(coord.lat), \(coord.lng))")
            let marker = NMFMarker(position: coord)
            marker.iconImage = NMFOverlayImage(name: "pinpoint_paw")
            marker.width = 25
            marker.height = 32
            marker.zIndex = 99
            marker.mapView = mapView.mapView
            context.coordinator.dogPlaceMarkers.append(marker)
        }
        print("🗺️ [AdvancedNaverMapView] dogPlace 마커 다시 추가 완료: \(context.coordinator.dogPlaceMarkers.count)개")
        
        print("🗺️ [AdvancedNaverMapView] updateUIView - centerCoordinate: \(centerCoordinate), zoomLevel: \(zoomLevel)")
        print("🗺️ [AdvancedNaverMapView] updateUIView - pathCoordinates: count=\(pathCoordinates.count)")
        if mapView.mapView.cameraPosition.target != centerCoordinate {
            let cameraUpdate = NMFCameraUpdate(scrollTo: centerCoordinate)
            cameraUpdate.animation = .easeIn
            mapView.mapView.moveCamera(cameraUpdate)
            print("🗺️ [AdvancedNaverMapView] 카메라 위치 업데이트: \(centerCoordinate)")
        }
        if mapView.mapView.cameraPosition.zoom != zoomLevel {
            let cameraUpdate = NMFCameraUpdate(zoomTo: zoomLevel)
            cameraUpdate.animation = .easeIn
            mapView.mapView.moveCamera(cameraUpdate)
            print("🗺️ [AdvancedNaverMapView] 줌 레벨 업데이트: \(zoomLevel)")
        }
        // 기본 내 위치 마커는 표시하되, 위치 추적 모드는 업데이트하지 않음
        // (초기 positionMode는 makeUIView에서만 설정하고 이후 업데이트에서는 변경하지 않음)
        mapView.mapView.locationOverlay.hidden = false // 기본 내 위치 마커 항상 표시
        
        // 사용자 위치 커스텀 마커 대신 기본 MyLocationOverlay 사용
        mapView.mapView.locationOverlay.hidden = false
        // positionMode 재설정 제거 - 사용자 지도 조작 유지
        
        // 경로 오버레이 업데이트 (방어 코드 추가)
        DispatchQueue.main.async {
            print("🚩 [AdvancedNaverMapView] 경로 오버레이 업데이트 시도 - 좌표 개수: \(pathCoordinates.count)")
            if pathCoordinates.count >= 2 {
                context.coordinator.updatePathOverlay(mapView: mapView.mapView, coordinates: pathCoordinates)
            } else {
                print("🚩 [AdvancedNaverMapView] 경로 오버레이 업데이트 실패 - 좌표가 2개 미만")
            }
        }
        
        print("🗺️ [AdvancedNaverMapView] updateUIView 완료")
    }
    
    func makeCoordinator() -> Coordinator {
        print("🗺️ [AdvancedNaverMapView] makeCoordinator 호출")
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, NMFMapViewTouchDelegate, NMFMapViewCameraDelegate {
        var dangerMarkers: [NMFMarker] = []
        var dogPlaceMarkers: [NMFMarker] = []
        let parent: AdvancedNaverMapView
        weak var pathOverlay: NMFPath?
        
        init(_ parent: AdvancedNaverMapView) {
            self.parent = parent
            print("🗺️ [AdvancedNaverMapView.Coordinator] 초기화")
        }
        
        // Update or add a new path overlay.
        func updatePathOverlay(mapView: NMFMapView, coordinates: [NMGLatLng]) {
            print("🗺️ [AdvancedNaverMapView.Coordinator] updatePathOverlay 호출 - coordinates: count=\(coordinates.count)")
            // 좌표 유효성 검사
            for (i, coord) in coordinates.enumerated() {
                guard abs(coord.lat) <= 90, abs(coord.lng) <= 180 else {
                    print("❌ [AdvancedNaverMapView.Coordinator] 유효하지 않은 좌표 (index \(i)): \(coord)")
                    return
                }
            }
            // 기존 오버레이 완전 제거
            if let existingPath = pathOverlay {
                print("🗺️ [AdvancedNaverMapView.Coordinator] 기존 pathOverlay 제거")
                existingPath.mapView = nil
                pathOverlay = nil
            }
            // 2개 미만 좌표면 오버레이 생성하지 않음
            guard coordinates.count >= 2 else {
                print("🗺️ [AdvancedNaverMapView.Coordinator] 좌표가 2개 미만이라 Polyline 생성하지 않음")
                return
            }
            print("🗺️ [AdvancedNaverMapView.Coordinator] NMFPath 생성 및 NMGLineString 할당 시도")
            let newPath = NMFPath()
            newPath.path = NMGLineString(points: coordinates)
            newPath.color = UIColor(red: 0.28, green: 0.81, blue: 0.43, alpha: 1.0)
            newPath.width = 5
            newPath.outlineWidth = 1
            newPath.mapView = mapView
            pathOverlay = newPath
            print("🗺️ [AdvancedNaverMapView.Coordinator] Polyline 정상 생성 및 지도에 추가 완료")
        }
        
        func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
            print("🗺️ [AdvancedNaverMapView.Coordinator] 지도 탭: \(latlng)")
            parent.onMapTapped?(latlng)
        }
        
        func mapViewCameraIdle(_ mapView: NMFMapView) {
            print("🗺️ [AdvancedNaverMapView.Coordinator] 카메라 이동 완료: center=\(mapView.cameraPosition.target), zoom=\(mapView.cameraPosition.zoom)")
            parent.centerCoordinate = mapView.cameraPosition.target
            parent.zoomLevel = mapView.cameraPosition.zoom
        }
    }
}

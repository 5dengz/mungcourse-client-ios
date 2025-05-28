import SwiftUI
import NMapsMap
import QuartzCore

struct AdvancedNaverMapView: UIViewRepresentable {
    @Binding var dangerCoordinates: [NMGLatLng]
    var dogPlaceCoordinates: [NMGLatLng] = []
    @Binding var centerCoordinate: NMGLatLng
    @Binding var zoomLevel: Double
    @Binding var pathCoordinates: [NMGLatLng]
    @Binding var userLocation: NMGLatLng?
    
    var onMapTapped: ((NMGLatLng) -> Void)?
    var onUserLocationUpdated: ((NMGLatLng) -> Void)?
    
    var showUserLocation: Bool = true
    var trackingMode: NMFMyPositionMode = .direction // 기본값: 위치 추적 활성화
    
    // 초기화
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
        // 맵뷰 생성
        let mapView = NMFNaverMapView()
        
        // 기본 설정
        mapView.showLocationButton = showUserLocation
        mapView.mapView.positionMode = trackingMode
        mapView.showZoomControls = true
        mapView.showCompass = true
        mapView.showScaleBar = true
        
        // danger 마커 표시
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
            marker.width = 25
            marker.height = 32
            marker.zIndex = 99
            marker.mapView = mapView.mapView
            context.coordinator.dogPlaceMarkers.append(marker)
        }
        
        // 위치 버튼 조정
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let buttons = mapView.subviews.compactMap { $0 as? UIButton }
            for btn in buttons {
                if btn.bounds.width == 48 && btn.bounds.height == 48 {
                    // 현위치 버튼으로 추정
                    btn.frame.origin = CGPoint(x: mapView.frame.width - 48 - 16, y: 16)
                }
            }
        }
        
        // 델리게이트 설정
        mapView.mapView.touchDelegate = context.coordinator
        mapView.mapView.addCameraDelegate(delegate: context.coordinator)
        
        // 카메라 초기 설정
        let cameraUpdate = NMFCameraUpdate(scrollTo: centerCoordinate, zoomTo: zoomLevel)
        mapView.mapView.moveCamera(cameraUpdate)
        
        // 경로 초기 설정 (2개 이상의 좌표가 있을 때만)
        if pathCoordinates.count >= 2 {
            context.coordinator.updatePathOverlay(mapView: mapView.mapView, coordinates: pathCoordinates)
        }
        
        return mapView
    }
    
    func updateUIView(_ mapView: NMFNaverMapView, context: Context) {
        // 마커 업데이트 - 실제 변경이 있을 때만 수행
        let isDangerChanged = !context.coordinator.areSameCoordinates(
            context.coordinator.prevDangerCoordinates, 
            dangerCoordinates
        )
        
        let isDogPlaceChanged = !context.coordinator.areSameCoordinates(
            context.coordinator.prevDogPlaceCoordinates, 
            dogPlaceCoordinates
        )
        
        // 카메라 변경 감지
        let isCameraChanged = context.coordinator.prevCenterCoordinate != centerCoordinate || 
                              context.coordinator.prevZoomLevel != zoomLevel
        
        // 경로 변경 감지
        let isPathChanged = !context.coordinator.areSameCoordinates(
            context.coordinator.prevPathCoordinates, 
            pathCoordinates
        )
        
        // 마커 업데이트
        if isDangerChanged || isDogPlaceChanged {
            // 기존 마커 제거
            for marker in context.coordinator.dangerMarkers {
                marker.mapView = nil
            }
            context.coordinator.dangerMarkers.removeAll()
            
            for marker in context.coordinator.dogPlaceMarkers {
                marker.mapView = nil
            }
            context.coordinator.dogPlaceMarkers.removeAll()
            
            // 마커 새로 추가
            for coord in dangerCoordinates {
                let marker = NMFMarker(position: coord)
                marker.iconImage = NMFOverlayImage(name: "pinpoint_danger")
                marker.width = 25
                marker.height = 32
                marker.zIndex = 100
                marker.mapView = mapView.mapView
                context.coordinator.dangerMarkers.append(marker)
            }
            
            for coord in dogPlaceCoordinates {
                let marker = NMFMarker(position: coord)
                marker.iconImage = NMFOverlayImage(name: "pinpoint_paw")
                marker.width = 25
                marker.height = 32
                marker.zIndex = 99
                marker.mapView = mapView.mapView
                context.coordinator.dogPlaceMarkers.append(marker)
            }
            
            // 상태 저장
            context.coordinator.prevDangerCoordinates = dangerCoordinates
            context.coordinator.prevDogPlaceCoordinates = dogPlaceCoordinates
        }
        
        // 카메라 위치 업데이트
        if isCameraChanged {
            let cameraUpdate = NMFCameraUpdate(scrollTo: centerCoordinate, zoomTo: zoomLevel)
            mapView.mapView.moveCamera(cameraUpdate)
            
            // 상태 저장
            context.coordinator.prevCenterCoordinate = centerCoordinate
            context.coordinator.prevZoomLevel = zoomLevel
        }
        
        // 사용자 위치 업데이트
        if let userLoc = userLocation, showUserLocation {
            mapView.mapView.locationOverlay.location = NMGLatLng(lat: userLoc.lat, lng: userLoc.lng)
            onUserLocationUpdated?(userLoc)
        }
        
        // 위치 표시 설정
        mapView.mapView.locationOverlay.hidden = !showUserLocation
        
        // 경로 업데이트
        if isPathChanged && pathCoordinates.count >= 2 {
            context.coordinator.updatePathOverlay(mapView: mapView.mapView, coordinates: pathCoordinates)
            
            // 상태 저장
            context.coordinator.prevPathCoordinates = pathCoordinates
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, NMFMapViewTouchDelegate, NMFMapViewCameraDelegate {
        var dangerMarkers: [NMFMarker] = []
        var dogPlaceMarkers: [NMFMarker] = []
        let parent: AdvancedNaverMapView
        weak var pathOverlay: NMFPath?
        
        // 이전 상태 추적을 위한 변수
        var prevDangerCoordinates: [NMGLatLng] = []
        var prevDogPlaceCoordinates: [NMGLatLng] = []
        var prevPathCoordinates: [NMGLatLng] = []
        var prevCenterCoordinate: NMGLatLng?
        var prevZoomLevel: Double = 0.0
        
        init(_ parent: AdvancedNaverMapView) {
            self.parent = parent
        }
        
        // 두 좌표 배열이 동일한지 비교하는 헬퍼 함수
        func areSameCoordinates(_ array1: [NMGLatLng], _ array2: [NMGLatLng]) -> Bool {
            // 배열 길이가 다르면 다른 경로
            if array1.count != array2.count {
                return false
            }
            
            // 각 좌표의 값 비교 - 참조 비교가 아닌 실제 값 비교로 변경
            for i in 0..<array1.count {
                if array1[i].lat != array2[i].lat || array1[i].lng != array2[i].lng {
                    return false
                }
            }
            
            return true
        }
        
        // 경로 오버레이 업데이트
        func updatePathOverlay(mapView: NMFMapView, coordinates: [NMGLatLng]) {
            // 기존 오버레이가 있으면 제거
            if let existingPath = pathOverlay {
                existingPath.mapView = nil
                pathOverlay = nil
            }
            
            // 2개 미만 좌표면 오버레이 생성하지 않음
            guard coordinates.count >= 2 else {
                return
            }
            
            // 새 경로 생성
            let newPath = NMFPath()
            newPath.path = NMGLineString(points: coordinates)
            newPath.color = UIColor(red: 0.28, green: 0.81, blue: 0.43, alpha: 1.0)
            newPath.width = 5
            newPath.outlineWidth = 1
            newPath.mapView = mapView
            pathOverlay = newPath
        }
        
        // 지도 탭 이벤트
        func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
            parent.onMapTapped?(latlng)
        }
        
        // 카메라 이동 완료 이벤트
        func mapViewCameraIdle(_ mapView: NMFMapView) {
            // 바인딩 상태 변경으로 무한 루프를 방지하기 위해 상태 값과 비교
            if !areSameLatLng(mapView.cameraPosition.target, prevCenterCoordinate) ||
               mapView.cameraPosition.zoom != prevZoomLevel {
                // 카메라가 실제로 바뀌었을 때만 업데이트
                prevCenterCoordinate = mapView.cameraPosition.target
                prevZoomLevel = mapView.cameraPosition.zoom
                
                // 부모에게 알림
                parent.centerCoordinate = mapView.cameraPosition.target
                parent.zoomLevel = mapView.cameraPosition.zoom
            }
        }
        
        // 좌표값 비교
        private func areSameLatLng(_ latlng1: NMGLatLng, _ latlng2: NMGLatLng?) -> Bool {
            guard let latlng2 = latlng2 else { return false }
            return latlng1.lat == latlng2.lat && latlng1.lng == latlng2.lng
        }
    }
}

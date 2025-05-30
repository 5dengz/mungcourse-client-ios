import SwiftUI
import NMapsMap

struct SimpleNaverMapView: UIViewRepresentable {
    var coordinates: [NMGLatLng]
    // 선택된 dog place 좌표
    var placeCoordinates: [NMGLatLng] = []
    var boundingBox: NMGLatLngBounds?
    var pathColor: UIColor = UIColor(named: "main") ?? .systemBlue
    var pathWidth: CGFloat = 5.0
    
    class OverlayHolder {
        var pathOverlay: NMFPath?
        var startMarker: NMFMarker?
        var endMarker: NMFMarker?
        // dog place 마커 저장
        var placeMarkers: [NMFMarker] = []
    }
    
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        mapView.positionMode = .direction
        mapView.zoomLevel = 15 // 초기 줌 레벨
        
        // 현재 위치 표시 제거
        mapView.locationOverlay.hidden = true
        
        // 네이버 로고 숨기기
        // mapView.logoAlign = .leftTop
        // mapView.logoMargin = UIEdgeInsets(top: -100, left: -100, bottom: 0, right: 0)
        
        // UI 설정
        mapView.isRotateGestureEnabled = false // 회전 제스처 비활성화
        mapView.isZoomGestureEnabled = true // 줌 제스처 활성화
        mapView.isScrollGestureEnabled = true // Pan 제스처 활성화
        
        // 오버레이 추적 객체 저장
        let holder = OverlayHolder()
        context.coordinator.overlayHolder = holder
        
        return mapView
    }
    
    func updateUIView(_ mapView: NMFMapView, context: Context) {
        // 기존 오버레이 제거
        if let path = context.coordinator.overlayHolder?.pathOverlay {
            path.mapView = nil
            context.coordinator.overlayHolder?.pathOverlay = nil
        }
        if let start = context.coordinator.overlayHolder?.startMarker {
            start.mapView = nil
            context.coordinator.overlayHolder?.startMarker = nil
        }
        if let end = context.coordinator.overlayHolder?.endMarker {
            end.mapView = nil
            context.coordinator.overlayHolder?.endMarker = nil
        }
        
        // 기존 dog place 마커 제거
        if let old = context.coordinator.overlayHolder?.placeMarkers {
            old.forEach { $0.mapView = nil }
            context.coordinator.overlayHolder?.placeMarkers.removeAll()
        }
        
        // 좌표가 있을 때만 경로 표시
        if !coordinates.isEmpty {
            drawPath(on: mapView, context: context)
            addMarkers(on: mapView, context: context)
            // dog place 마커 추가
            addPlaceMarkers(on: mapView, context: context)
            
            // 경로에 맞게 지도 영역 조정 (첫 로드시에만)
            if !context.coordinator.initialCameraSet, let firstCoord = coordinates.first {
                mapView.moveCamera(NMFCameraUpdate(scrollTo: firstCoord))
                context.coordinator.initialCameraSet = true
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var overlayHolder: OverlayHolder?
        var initialCameraSet = false
    }
    
    // 경로 그리기
    private func drawPath(on mapView: NMFMapView, context: Context) {
        let path = NMFPath()
        path.path = NMGLineString(points: coordinates)
        path.color = pathColor
        path.width = pathWidth
        path.outlineColor = UIColor.white.withAlphaComponent(0.5)
        path.outlineWidth = 2
        path.mapView = mapView
        context.coordinator.overlayHolder?.pathOverlay = path
    }
    
    // 시작점과 종료점 마커 추가
    private func addMarkers(on mapView: NMFMapView, context: Context) {
        guard let start = coordinates.first, let end = coordinates.last else {
            return
        }
        // 시작 마커
        let startMarker = NMFMarker()
        startMarker.position = start
        if let iconImage = UIImage(named: "pinpoint_paw") {
            // 핀포인트 이미지 31x39로 리사이즈
            let size = CGSize(width: 31, height: 39)
            let renderer = UIGraphicsImageRenderer(size: size)
            let resizedImage = renderer.image { _ in
                iconImage.draw(in: CGRect(origin: .zero, size: size))
            }
            startMarker.iconImage = NMFOverlayImage(image: resizedImage)
        }
        // Asset Catalog의 "main" 컬러 사용
        startMarker.captionText = "시작"
        startMarker.captionColor = UIColor(named: "main")!
        startMarker.mapView = mapView
        context.coordinator.overlayHolder?.startMarker = startMarker
        // 종료 마커 (시작점과 종료점이 다를 경우에만)
        if start.lat != end.lat || start.lng != end.lng {
            let endMarker = NMFMarker()
            endMarker.position = end
            if let iconImage = UIImage(named: "pinpoint_paw") {
                // 핀포인트 이미지 31x39로 리사이즈
                let size = CGSize(width: 31, height: 39)
                let renderer = UIGraphicsImageRenderer(size: size)
                let resizedImage = renderer.image { _ in
                    iconImage.draw(in: CGRect(origin: .zero, size: size))
                }
                endMarker.iconImage = NMFOverlayImage(image: resizedImage)
            }
            // Asset Catalog의 "main" 컬러 사용
            endMarker.captionText = "종료"
            endMarker.captionColor = UIColor(named: "main")!
            endMarker.mapView = mapView
            context.coordinator.overlayHolder?.endMarker = endMarker
        }
    }
    
    // dog place 마커 추가
    private func addPlaceMarkers(on mapView: NMFMapView, context: Context) {
        for coord in placeCoordinates {
            let marker = NMFMarker(position: coord)
            marker.iconImage = NMFOverlayImage(name: "pinpoint_paw")
            marker.width = 25; marker.height = 32
            marker.mapView = mapView
            context.coordinator.overlayHolder?.placeMarkers.append(marker)
        }
    }
}
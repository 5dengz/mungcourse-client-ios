import SwiftUI
import NMapsMap

struct SimpleNaverMapView: UIViewRepresentable {
    var coordinates: [NMGLatLng]
    var boundingBox: NMGLatLngBounds?
    var pathColor: UIColor = UIColor(named: "main") ?? .systemBlue
    var pathWidth: CGFloat = 5.0
    
    class OverlayHolder {
        var pathOverlay: NMFPath?
        var startMarker: NMFMarker?
        var endMarker: NMFMarker?
    }
    
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        mapView.positionMode = .direction
        mapView.zoomLevel = 15 // 초기 줌 레벨
        
        // 네이버 로고 숨기기
        mapView.logoAlign = .leftTop
        mapView.logoMargin = UIEdgeInsets(top: -100, left: -100, bottom: 0, right: 0)
        
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
        
        // 좌표가 있을 때만 경로 표시
        if !coordinates.isEmpty {
            drawPath(on: mapView, context: context)
            addMarkers(on: mapView, context: context)
            
            // 경로에 맞게 지도 영역 조정
            if let firstCoord = coordinates.first {
                mapView.moveCamera(NMFCameraUpdate(scrollTo: firstCoord))
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var overlayHolder: OverlayHolder?
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
            startMarker.iconImage = NMFOverlayImage(image: iconImage)
        }
        startMarker.iconTintColor = .systemGreen
        startMarker.captionText = "시작"
        startMarker.captionColor = .systemGreen
        startMarker.mapView = mapView
        context.coordinator.overlayHolder?.startMarker = startMarker
        // 종료 마커 (시작점과 종료점이 다를 경우에만)
        if start.lat != end.lat || start.lng != end.lng {
            let endMarker = NMFMarker()
            endMarker.position = end
            endMarker.iconImage = NMF_MARKER_IMAGE_RED
            endMarker.iconTintColor = .systemRed
            endMarker.captionText = "종료"
            endMarker.captionColor = .systemRed
            endMarker.mapView = mapView
            context.coordinator.overlayHolder?.endMarker = endMarker
        }
    }
}
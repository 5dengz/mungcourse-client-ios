import SwiftUI
import NMapsMap

struct NaverMapView: UIViewRepresentable {
    var coordinates: [NMGLatLng]
    var boundingBox: NMGLatLngBounds?
    var pathColor: UIColor = .systemBlue
    var pathWidth: CGFloat = 5.0
    
    // UIView 생성
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        mapView.positionMode = .direction
        mapView.zoomLevel = 15 // 초기 줌 레벨
        
        // UI 설정
        mapView.isRotateGestureEnabled = false // 회전 제스처 비활성화
        mapView.isZoomGestureEnabled = true // 줌 제스처 활성화
        mapView.isPanGestureEnabled = true // 이동 제스처 활성화
        
        return mapView
    }
    
    // UIView 업데이트
    func updateUIView(_ mapView: NMFMapView, context: Context) {
        // 이전에 그린 경로 제거
        if let overlays = mapView.overlays {
            for overlay in overlays {
                overlay.mapView = nil
            }
        }
        
        // 좌표가 있을 때만 경로 표시
        if !coordinates.isEmpty {
            drawPath(on: mapView)
            addMarkers(on: mapView)
            
            // 경로에 맞게 지도 영역 조정
            if let bounds = boundingBox {
                mapView.moveCamera(NMFCameraUpdate(fit: bounds, padding: 50))
            } else if let firstCoord = coordinates.first {
                // 바운딩 박스가 없으면 첫 좌표로 이동
                mapView.moveCamera(NMFCameraUpdate(scrollTo: firstCoord))
            }
        }
    }
    
    // 경로 그리기
    private func drawPath(on mapView: NMFMapView) {
        let path = NMFPath()
        path.path = NMGLineString(points: coordinates)
        path.color = pathColor
        path.width = pathWidth
        path.outlineColor = UIColor.white.withAlphaComponent(0.5)
        path.outlineWidth = 2
        path.mapView = mapView
    }
    
    // 시작점과 종료점 마커 추가
    private func addMarkers(on mapView: NMFMapView) {
        guard let start = coordinates.first, let end = coordinates.last else {
            return
        }
        
        // 시작 마커
        let startMarker = NMFMarker()
        startMarker.position = start
        startMarker.iconImage = NMF_MARKER_IMAGE_GREEN
        startMarker.iconTintColor = .systemGreen
        startMarker.captionText = "시작"
        startMarker.captionColor = .systemGreen
        startMarker.mapView = mapView
        
        // 종료 마커 (시작점과 종료점이 다를 경우에만)
        if start.lat != end.lat || start.lng != end.lng {
            let endMarker = NMFMarker()
            endMarker.position = end
            endMarker.iconImage = NMF_MARKER_IMAGE_RED
            endMarker.iconTintColor = .systemRed
            endMarker.captionText = "종료"
            endMarker.captionColor = .systemRed
            endMarker.mapView = mapView
        }
    }
}
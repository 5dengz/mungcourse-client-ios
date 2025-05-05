import SwiftUI
import NMapsMap

struct NearbyTrailMapDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let place: DogPlace

    var body: some View {
        VStack(spacing: 0) {
            CommonHeaderView(leftIcon: "arrow_back", leftAction: { dismiss() }, title: place.name) {
                Image("tab_map")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            NaverMapViewRepresentable(lat: place.lat, lng: place.lng)
                .edgesIgnoringSafeArea(.bottom)
        }
    }
}

// Naver Maps SwiftUI 래퍼
struct NaverMapViewRepresentable: UIViewRepresentable {
    let lat: Double
    let lng: Double

    func makeUIView(context: Context) -> NMFNaverMapView {
        let mapView = NMFNaverMapView()
        mapView.showZoomControls = false
        mapView.showLocationButton = false
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
        mapView.mapView.moveCamera(cameraUpdate)

        // 마커 추가
        let marker = NMFMarker(position: NMGLatLng(lat: lat, lng: lng))
        marker.iconImage = NMFOverlayImage(name: "pinpoint_paw")
        marker.width = 48
        marker.height = 48
        marker.mapView = mapView.mapView
        return mapView
    }

    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        // 필요시 업데이트
    }
} 
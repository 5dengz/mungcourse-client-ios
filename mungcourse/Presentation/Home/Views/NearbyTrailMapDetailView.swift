import SwiftUI
import NMapsMap
import UIKit

struct NearbyTrailMapDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let place: DogPlace

    var body: some View {
        VStack(spacing: 0) {
            CommonHeaderView(leftIcon: "arrow_back", leftAction: { dismiss() }, title: place.name)
            .padding(.vertical, 16)
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

        // effect 마커 추가
        let effectImage = UIImage(named: "pinpoint_effect")
        let effect = NMFMarker()
        if let effectImage = effectImage {
            effect.iconImage = NMFOverlayImage(image: effectImage)
        }
        effect.width = 30
        effect.height = 14
        effect.anchor = CGPoint(x: 0.5, y: 0.5)
        effect.zIndex = 0
        effect.position = NMGLatLng(lat: lat, lng: lng)
        effect.mapView = mapView.mapView
        context.coordinator.effectMarker = effect

        // paw 마커 추가
        let pawImage = UIImage(named: "pinpoint_paw")
        let paw = NMFMarker()
        if let pawImage = pawImage {
            paw.iconImage = NMFOverlayImage(image: pawImage)
        }
        paw.width = 25
        paw.height = 32
        paw.anchor = CGPoint(x: 0.5, y: 1.0)
        paw.zIndex = 1
        paw.position = NMGLatLng(lat: lat, lng: lng)
        paw.mapView = mapView.mapView
        context.coordinator.pawMarker = paw

        // effect 애니메이션 시작
        context.coordinator.startEffectAnimation()

        return mapView
    }

    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        // 필요시 업데이트
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    // Coordinator for effect animation
    class Coordinator {
        var effectMarker: NMFMarker?
        var pawMarker: NMFMarker?
        var timer: Timer?

        func startEffectAnimation() {
            timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] timer in
                guard let effect = self?.effectMarker else { timer.invalidate(); return }
                let scale = 0.8 + 0.5 * sin(Date.timeIntervalSinceReferenceDate)
                effect.width = 30 * scale
                effect.height = 14 * scale
            }
        }
    }
}
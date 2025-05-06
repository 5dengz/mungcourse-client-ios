import SwiftUI
import NMapsMap

struct RoutePreviewView: View {
    let coordinates: [NMGLatLng]
    let distance: Double
    let estimatedTime: Int
    let waypoints: [DogPlace]
    @Environment(\.dismiss) private var dismiss
    @State private var showStartWalk = false

    var body: some View {
        VStack(spacing: 0) {
            CommonHeaderView(
                leftIcon: "arrow_back",
                leftAction: { dismiss() },
                title: "추천 경로 미리보기"
            )

            SimpleNaverMapView(
                coordinates: coordinates,
                boundingBox: nil,
                pathColor: UIColor(named: "main") ?? .systemBlue,
                pathWidth: 5
            )
            .edgesIgnoringSafeArea(.horizontal)
            .frame(maxHeight: .infinity)

            CommonFilledButton(
                title: "이 코스로 산책 시작",
                action: { showStartWalk = true },
                isEnabled: true,
                backgroundColor: Color("main")
            )
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showStartWalk) {
            StartWalkView(
                routeOption: RouteOption(
                    type: .recommended,
                    totalDistance: distance,
                    estimatedTime: estimatedTime,
                    waypoints: waypoints,
                    coordinates: coordinates
                )
            )
        }
    }
}

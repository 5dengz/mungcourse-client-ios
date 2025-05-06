import SwiftUI
import NMapsMap

struct RoutePreviewView: View {
    let coordinates: [NMGLatLng]
    let distance: Double
    let estimatedTime: Int
    let waypoints: [DogPlace]
    // 홈 복귀 콜백 (경유지 선택 플로우 해제)
    var onForceHome: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var showStartWalk = false
    // 환경객체 전달
    @EnvironmentObject var dogVM: DogViewModel

    var body: some View {
        VStack(spacing: 0) {
            CommonHeaderView(
                leftIcon: "arrow_back",
                leftAction: { dismiss() },
                title: "추천 경로 미리보기"
            )

            SimpleNaverMapView(
                coordinates: coordinates,
                placeCoordinates: waypoints.map { NMGLatLng(lat: $0.lat, lng: $0.lng) },
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
            NavigationStack {
                StartWalkView(
                    routeOption: RouteOption(
                        type: .recommended,
                        totalDistance: distance,
                        estimatedTime: estimatedTime,
                        waypoints: waypoints,
                        coordinates: coordinates
                    ),
                    onForceHome: {
                        showStartWalk = false
                        onForceHome?()
                    }
                )
                .environmentObject(dogVM)
            }
        }
    }
}

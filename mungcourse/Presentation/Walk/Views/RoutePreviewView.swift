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
        .navigationDestination(isPresented: $showStartWalk) {
            StartWalkView(
                routeOption: RouteOption(
                    type: .recommended,
                    totalDistance: distance,
                    estimatedTime: estimatedTime,
                    waypoints: waypoints,
                    coordinates: {
                        // 좌표 로그 출력
                        print("🗯️ [RoutePreviewView] 경로 좌표 목록:")
                        for (index, coord) in coordinates.enumerated() {
                            print("🗯️ [RoutePreviewView]   [\(index)] lat: \(coord.lat), lng: \(coord.lng)")
                        }
                        print("🗯️ [RoutePreviewView] 총 \(coordinates.count)개의 좌표 전달")
                        return coordinates
                    }()
                ),
                onForceHome: { 
                    // 모든 메뉴를 다 닫고 홈으로 가도록 한번에 처리
                    showStartWalk = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        dismiss()
                        onForceHome?()
                    }
                }
            )
            .environmentObject(dogVM)
            .navigationBarBackButtonHidden(true)
        }
    }
}

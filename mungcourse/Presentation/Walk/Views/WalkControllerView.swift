import SwiftUI

struct WalkControllerView: View {
    let distance: String
    let duration: String
    let calories: String
    let state: WalkControlButton.WalkState
    let onStart: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onEnd: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            WalkStatsBar(
                distance: distance,
                duration: duration,
                calories: calories,
                isActive: state == .active // 산책 중일 때만 main 컬러
            )
            .padding(.top, 12)
            WalkControlButton(
                state: state,
                onStart: onStart,
                onPause: onPause,
                onResume: onResume,
                onEnd: onEnd
            )
            .padding(.top, 12)
            .padding(.bottom, 24)
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .frame(maxWidth: .infinity)
        .background(
            Color("pointwhite")
                .ignoresSafeArea(edges: .bottom)
        )
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: Color("black10").opacity(0.1), radius: 10, x: 0, y: -5)
    }
}

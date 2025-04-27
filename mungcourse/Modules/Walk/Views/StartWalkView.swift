import SwiftUI
import NMapsMap

struct StartWalkView: View {
    @StateObject private var viewModel = StartWalkViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showCompleteAlert = false
    @State private var completedSession: WalkSession? = nil
    @State private var effectScale: CGFloat = 0.5
    @State private var effectOpacity: Double = 1.0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content area
            VStack(spacing: 0) {
                // Map View
                ZStack {
                    // Map View
                    NaverMapView(
                        centerCoordinate: $viewModel.centerCoordinate,
                        zoomLevel: $viewModel.zoomLevel,
                        pathCoordinates: $viewModel.pathCoordinates,
                        userLocation: $viewModel.userLocation,
                        showUserLocation: true,
                        trackingMode: .direction
                    )
                    .edgesIgnoringSafeArea(.all)
                }
            }
            
            // Bottom controller panel
            WalkControllerView(
                distance: viewModel.formattedDistance,
                duration: viewModel.formattedDuration,
                calories: viewModel.formattedCalories,
                state: viewModel.isPaused ? .paused : (viewModel.isWalking ? .active : .notStarted),
                onStart: { viewModel.startWalk() },
                onPause: { viewModel.pauseWalk() },
                onResume: { viewModel.resumeWalk() },
                onEnd: {
                    completedSession = viewModel.endWalk()
                    if completedSession != nil {
                        showCompleteAlert = true
                    }
                }
            )
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationBarHidden(true)
        .overlay(
            WalkHeaderView(onBack: { dismiss() }),
            alignment: .top
        )
        .alert("산책 완료", isPresented: $showCompleteAlert) {
            Button("확인") {
                dismiss()
            }
        } message: {
            Text("총 거리: \(viewModel.formattedDistance)km\n소요 시간: \(viewModel.formattedDuration)\n소모 칼로리: \(viewModel.formattedCalories)kcal")
        }
    }
}

// Extension for rounded corners on specific edges
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// Custom shape for rounded corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    NavigationStack {
        StartWalkView()
    }
}

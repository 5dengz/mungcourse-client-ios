import SwiftUI
import NMapsMap

struct StartWalkView: View {
    @StateObject private var viewModel = StartWalkViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showCompleteAlert = false
    @State private var completedSession: WalkSession? = nil
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content area
            VStack(spacing: 0) {
                // Map View
                NaverMapView(
                    centerCoordinate: $viewModel.centerCoordinate,
                    zoomLevel: $viewModel.zoomLevel,
                    pathCoordinates: $viewModel.pathCoordinates,
                    showUserLocation: true,
                    trackingMode: .direction
                )
                .edgesIgnoringSafeArea(.all)
            }
            
            // Bottom stats panel with shadow and rounded corners
            VStack(spacing: 0) {
                WalkStatsBar(
                    distance: viewModel.formattedDistance,
                    duration: viewModel.formattedDuration,
                    calories: viewModel.formattedCalories
                )
                
                WalkControlButton(
                    state: viewModel.isPaused ? .paused : (viewModel.isWalking ? .active : .notStarted),
                    onStart: {
                        viewModel.startWalk()
                    },
                    onPause: {
                        viewModel.pauseWalk()
                    },
                    onResume: {
                        viewModel.resumeWalk()
                    },
                    onEnd: {
                        completedSession = viewModel.endWalk()
                        if completedSession != nil {
                            showCompleteAlert = true
                        }
                    }
                )
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("산책 시작")
                    .font(.headline)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
            }
        }
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

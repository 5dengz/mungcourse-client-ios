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
            // Debug: view appear
            Color.clear
                .onAppear { print("[디버그] StartWalkView onAppear") }
                .onChange(of: viewModel.isWalking) { newValue, oldValue in
                    print("[디버그] isWalking changed: \(newValue)")
                }
                .onChange(of: viewModel.pathCoordinates) { newPath, oldPath in
                    print("[디버그] StartWalkView pathCoordinates: \(newPath)")
                }
            // Content area
            VStack(spacing: 0) {
                // Map View
                ZStack {
                    NaverMapView(
                        centerCoordinate: $viewModel.centerCoordinate,
                        zoomLevel: $viewModel.zoomLevel,
                        pathCoordinates: $viewModel.pathCoordinates,
                        userLocation: $viewModel.userLocation,
                        showUserLocation: true,
                        trackingMode: .direction
                    )
                    .onAppear { print("[디버그] NaverMapView appear in StartWalkView") }
                    .onChange(of: viewModel.centerCoordinate) { newCoord, oldCoord in
                        print("[디버그] viewModel.centerCoordinate: \(newCoord)")
                    }
                    .edgesIgnoringSafeArea(.all)
                }
            }
            // Bottom controller panel
            WalkControllerView(
                distance: viewModel.formattedDistance,
                duration: viewModel.formattedDuration,
                calories: viewModel.formattedCalories,
                state: viewModel.isPaused ? .paused : (viewModel.isWalking ? .active : .notStarted),
                onStart: {
                    print("[디버그] WalkControllerView onStart pressed")
                    viewModel.startWalk()
                },
                onPause: {
                    print("[디버그] WalkControllerView onPause pressed")
                    viewModel.pauseWalk()
                },
                onResume: {
                    print("[디버그] WalkControllerView onResume pressed")
                    viewModel.resumeWalk()
                },
                onEnd: {
                    print("[디버그] WalkControllerView onEnd pressed")
                    completedSession = viewModel.endWalk()
                    if let session = completedSession {
                        // TODO: 실제 dogIds를 선택받아야 함. 임시로 [1] 사용
                        viewModel.uploadWalkSession(session, dogIds: [1]) { success in
                            // 업로드 성공/실패에 따라 알림 등 처리 가능
                        }
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
        .alert("위치 권한 필요", isPresented: $viewModel.showPermissionAlert) {
            Button("설정으로 이동") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("산책을 시작하려면 위치 권한이 필요합니다.\n설정에서 위치 권한을 허용해주세요.")
        }
        .alert("위치 서비스 에러", isPresented: $viewModel.showLocationErrorAlert) {
            Button("확인") {}
        } message: {
            Text(viewModel.locationErrorMessage)
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

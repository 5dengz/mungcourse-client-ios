import SwiftUI
import NMapsMap

struct RouteWalkView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: RouteWalkViewModel
    @State private var showCompleteAlert = false
    @State private var showCompleteView = false
    @State private var completedSession: WalkSession? = nil
    
    init(route: RouteOption) {
        _viewModel = StateObject(wrappedValue: RouteWalkViewModel(route: route))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 컨텐츠 영역
            VStack(spacing: 0) {
                // 네이버 지도
                AdvancedNaverMapView(
                    dangerCoordinates: $viewModel.dangerCoordinates,
                    centerCoordinate: $viewModel.centerCoordinate,
                    zoomLevel: $viewModel.zoomLevel,
                    pathCoordinates: $viewModel.pathCoordinates,
                    userLocation: $viewModel.userLocation,
                    showUserLocation: true,
                    trackingMode: .direction
                )
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    // 경로 진행 상태 표시
                    VStack {
                        if viewModel.isWalking {
                            Text("경로 진행률: \(viewModel.formattedProgress)")
                                .font(.caption)
                                .padding(8)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(8)
                                .padding(.top, 50)
                        }
                        Spacer()
                    }
                )
            }
            
            // 산책 컨트롤 패널
            WalkControllerView(
                distance: viewModel.formattedDistance,
                duration: viewModel.formattedDuration,
                calories: viewModel.formattedCalories,
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
                    if let session = completedSession {
                        // TODO: 실제 dogIds를 선택받아야 함
                        viewModel.uploadWalkSession(session, dogIds: [1]) { success in
                            if success {
                                print("✅ 산책 데이터 업로드 성공")
                                // 산책 완료 화면으로 이동
                                showCompleteView = true
                            } else {
                                print("❌ 산책 데이터 업로드 실패")
                                // 실패 시에도 일단 산책 완료 화면으로 이동
                                showCompleteView = true
                            }
                        }
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
        // 산책 완료 화면 표시
        .fullScreenCover(isPresented: $showCompleteView) {
            if let session = completedSession {
                let walkData = WalkSessionData(
                    distance: session.distance,
                    duration: Int(session.duration),
                    date: session.endTime,
                    coordinates: session.path
                )
                NavigationStack {
                    WalkCompleteView(walkData: walkData)
                }
            }
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


import SwiftUI
import NMapsMap

struct StartWalkBottomView: View {
    @ObservedObject var viewModel: StartWalkViewModel
    @EnvironmentObject var dogVM: DogViewModel
    @Binding var completedSession: WalkSession?
    @Binding var isCompleteActive: Bool
    var onForceHome: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            WalkControllerView(
                distance: viewModel.formattedDistance,
                duration: viewModel.formattedDuration,
                calories: viewModel.formattedCalories,
                state: viewModel.isPaused ? .paused : (viewModel.isWalking ? .active : .notStarted),
                onStart: { viewModel.startWalk() },
                onPause: { viewModel.pauseWalk() },
                onResume: { viewModel.resumeWalk() },
                onEnd: {
                    // 산책 종료 후 즉시 내비게이션 활성화
                    completedSession = viewModel.endWalk()
                    isCompleteActive = true
                    // 백그라운드로 세션 업로드
                    if let session = completedSession, let mainId = dogVM.mainDog?.id {
                        let dogIds = [mainId]
                        viewModel.uploadWalkSession(session, dogIds: dogIds) { _ in
                            // 업로드 완료, UI 이미 이동
                        }
                    }
                }
            )
            // 산책 완료 화면 네비게이션
            NavigationLink(isActive: $isCompleteActive) {
                if let session = completedSession {
                    let walkData = WalkSessionData(
                        distance: session.distance,
                        duration: Int(session.duration),
                        date: session.endTime,
                        coordinates: session.path
                    )
                    WalkCompleteView(walkData: walkData, onForceDismiss: onForceHome)
                } else {
                    EmptyView()
                }
            } label: {
                EmptyView()
            }
            .hidden()
        }
        .padding()
        .background(Color("pointwhite"))
    }
} 
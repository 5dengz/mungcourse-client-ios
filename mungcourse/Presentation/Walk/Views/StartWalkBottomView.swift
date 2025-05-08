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
                    // 산책 종료
                    completedSession = viewModel.endWalk()
                    
                    // 즉시 네비게이션 활성화
                    isCompleteActive = true
                    
                    // 백그라운드로 세션 업로드
                    if let session = completedSession, let mainId = dogVM.mainDog?.id {
                        let dogIds = [mainId]
                        DispatchQueue.global(qos: .background).async {
                            viewModel.uploadWalkSession(session, dogIds: dogIds) { _ in }
                        }
                    }
                }
            )
            // 산책 완료 화면 네비게이션
            NavigationLink(isActive: $isCompleteActive) {
                if let session = completedSession {
                    // 이제 WalkSessionData를 생성하지 않고 직접 WalkSession 전달
                    WalkCompleteView(walkData: session, onForceDismiss: onForceHome)
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
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
                    completedSession = viewModel.endWalk()
                    if let session = completedSession {
                        if let mainId = dogVM.mainDog?.id {
                            let dogIds = [mainId]
                            viewModel.uploadWalkSession(session, dogIds: dogIds) { _ in
                                isCompleteActive = true
                            }
                        } else {
                            isCompleteActive = true
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
        .background(Color.white)
    }
} 
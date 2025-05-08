import SwiftUI
import NMapsMap

struct WalkCompleteView: View {
    @StateObject private var viewModel = WalkCompleteViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dogVM: DogViewModel
    @State private var isGoHome = false
    
    var onForceDismiss: (() -> Void)? = nil
    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더 (날짜 데이터 ViewModel에서 사용)
            WalkCompleteHeader(walkDate: viewModel.walkDate, onClose: {
                dismiss()
            }, dogViewModel: dogVM) // DogViewModel을 매개변수로 직접 전달
            .padding(.bottom, 8)

            ScrollView {
                // 산책 경로 지도+통계 통합 뷰
                WalkRouteSummaryView(
                    coordinates: viewModel.pathCoordinates,
                    distance: viewModel.distance,
                    duration: viewModel.duration,
                    calories: viewModel.calories,
                    isLoading: false,
                    errorMessage: nil,
                    emptyMessage: "저장된 경로 정보가 없습니다",
                    boundingBox: nil,
                    mapHeight: 300
                )
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("pointwhite"))
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }

            Spacer(minLength: 0)

            // 홈으로 이동 버튼
            CommonFilledButton(title: "홈으로 이동", action: {
                dismiss() // 1차 해제
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onForceDismiss?() // 2차 해제(최상위)
                }
            })
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color("pointwhite").ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    // 사용자 정의 이니셜라이저로 ViewModel 초기화 가능
    init(walkData: WalkSessionData? = nil, onForceDismiss: (() -> Void)? = nil) {
        let vm = WalkCompleteViewModel(walkData: walkData)
        _viewModel = StateObject(wrappedValue: vm)
        self.onForceDismiss = onForceDismiss
    }
}

#Preview {
    WalkCompleteView()
}

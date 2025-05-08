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
                .padding(.top, 12)
                .padding(.bottom, 24)
            }

            Spacer(minLength: 0)

            // 홈으로 이동 버튼
            CommonFilledButton(title: "홈으로 이동", action: {
                // dismiss() 호출을 제거하고 바로 onForceDismiss?() 호출
                onForceDismiss?() // 모든 화면 한 번에 해제
            })
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color("pointwhite").ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    // 사용자 정의 이니셜라이저로 ViewModel 초기화 가능
    init(walkData: WalkSession? = nil, onForceDismiss: (() -> Void)? = nil) {
        // WalkSession에서 필요한 데이터 추출
        let sessionData: WalkSessionData? = walkData.map { session in
            // WalkSession에서 WalkSessionData로 변환
            WalkSessionData(
                distance: session.distance,
                duration: Int(session.duration),
                date: session.endTime,
                coordinates: session.path
            )
        }
        
        let vm = WalkCompleteViewModel(walkData: sessionData)
        _viewModel = StateObject(wrappedValue: vm)
        self.onForceDismiss = onForceDismiss
    }
}
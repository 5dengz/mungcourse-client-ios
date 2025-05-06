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
            })
            .padding(.bottom, 8)

            ScrollView {
                VStack(spacing: 32) {
                    // 산책 경로 섹션
                    VStack(alignment: .leading, spacing: 16) {
                        Text("산책 경로")
                            .font(.title3)
                            .fontWeight(.semibold)
                        WalkStatsBar(
                            distance: viewModel.distance,
                            duration: viewModel.duration,
                            calories: viewModel.calories,
                            isActive: false
                        )
                        // 네이버 지도 (경로 표시)
                        AdvancedNaverMapView(
                            dangerCoordinates: .constant(viewModel.dangerCoordinates),
                            centerCoordinate: .constant(viewModel.centerCoordinate),
                            zoomLevel: .constant(viewModel.zoomLevel),
                            pathCoordinates: .constant(viewModel.pathCoordinates),
                            userLocation: .constant(nil),
                            showUserLocation: false,
                            trackingMode: .direction
                        )
                        .frame(height: 180)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 8)
                .padding(.bottom, 32)
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
        .background(Color("white").ignoresSafeArea())
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

import SwiftUI
import NMapsMap

struct WalkCompleteView: View {
    @StateObject private var viewModel = WalkCompleteViewModel()
    @Environment(\.dismiss) private var dismiss
    
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

                    // 오늘의 총 산책 섹션
                    VStack(alignment: .leading, spacing: 16) {
                        Text("오늘의 총 산책")
                            .font(.title3)
                            .fontWeight(.semibold)
                        WalkStatsBar(
                            distance: viewModel.distance,
                            duration: viewModel.duration,
                            calories: viewModel.calories,
                            isActive: false
                        )
                        // 그래프 영역 (추후 구현)
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 80)
                            .overlay(Text("그래프 영역").foregroundColor(.gray))
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
                // 바로 홈으로 이동
                dismiss()
            })
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color("white").ignoresSafeArea())
    }
    
    // 사용자 정의 이니셜라이저로 ViewModel 초기화 가능
    init(walkData: WalkSessionData? = nil) {
        let vm = WalkCompleteViewModel(walkData: walkData)
        _viewModel = StateObject(wrappedValue: vm)
    }
}

#Preview {
    WalkCompleteView()
}

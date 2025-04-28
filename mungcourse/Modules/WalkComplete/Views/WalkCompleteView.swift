import SwiftUI
import NMapsMap

struct WalkCompleteView: View {
    // 임시 데이터, 실제 데이터 연동 시 파라미터로 전달
    var distance: String = "1.2"
    var duration: String = "00:05:10"
    var calories: String = "25"
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더
            WalkCompleteHeader(onClose: {
                // 홈 이동 액션 (네비게이션에서 처리)
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
                            distance: distance,
                            duration: duration,
                            calories: calories,
                            isActive: false
                        )
                        // 네이버 지도 (경로 표시 예정, 일단 지도만)
                        NaverMapView(
                            centerCoordinate: .constant(NMGLatLng(lat: 37.5665, lng: 126.9780)),
                            zoomLevel: .constant(16.0),
                            pathCoordinates: .constant([]),
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
                            distance: distance,
                            duration: duration,
                            calories: calories,
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
                // 홈 이동 액션 (네비게이션에서 처리)
            })
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color("white").ignoresSafeArea())
    }
}

#Preview {
    WalkCompleteView()
}

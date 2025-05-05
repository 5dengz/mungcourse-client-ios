// WalkRouteSummaryView.swift
// 산책 경로 지도 + 통계 재사용 컴포넌트
import SwiftUI
import NMapsMap

struct WalkRouteSummaryView: View {
    // 지도 경로 좌표
    let coordinates: [NMGLatLng]
    // 통계 데이터
    let distance: String
    let duration: String
    let calories: String
    // 상태
    let isLoading: Bool
    let errorMessage: String?
    let emptyMessage: String?
    let boundingBox: NMGLatLngBounds?
    // 지도 높이
    var mapHeight: CGFloat = 180

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if isLoading {
                    Color("gray200")
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.2)
                } else if let error = errorMessage {
                    Color("gray200")
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                        Text("산책 기록을 불러올 수 없습니다")
                            .font(.custom("Pretendard-Medium", size: 16))
                            .padding(.top, 4)
                        Text(error)
                            .font(.custom("Pretendard-Regular", size: 12))
                            .foregroundColor(Color("gray600"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                } else if coordinates.isEmpty {
                    Color("gray200")
                    VStack {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 24))
                            .foregroundColor(Color("gray600"))
                        Text(emptyMessage ?? "산책 경로 데이터가 없습니다")
                            .font(.custom("Pretendard-Medium", size: 16))
                            .padding(.top, 4)
                        Text("산책을 시작해보세요!")
                            .font(.custom("Pretendard-Regular", size: 14))
                            .foregroundColor(Color("gray600"))
                    }
                } else {
                    SimpleNaverMapView(
                        coordinates: coordinates,
                        boundingBox: boundingBox,
                        pathColor: UIColor(named: "main") ?? .systemBlue,
                        pathWidth: 5.0
                    )
                }
            }
            .frame(height: mapHeight)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // 통계 바
            WalkStatsBar(
                distance: distance,
                duration: duration,
                calories: calories,
                isActive: false
            )
        }
    }
}

// 미리보기용 더미 데이터
#if DEBUG
import NMapsGeometry
struct WalkRouteSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        WalkRouteSummaryView(
            coordinates: [NMGLatLng(lat: 37.5665, lng: 126.9780), NMGLatLng(lat: 37.567, lng: 126.979)],
            distance: "1.25",
            duration: "10:30",
            calories: "120",
            isLoading: false,
            errorMessage: nil,
            emptyMessage: nil,
            boundingBox: nil
        )
        .padding()
    }
}
#endif

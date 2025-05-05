import SwiftUI
import UIKit
import NMapsGeometry

struct PastRoutesView: View {
    @StateObject private var viewModel = PastRoutesViewModel()
    var onShowDetail: ((Date) -> Void)? = nil
    var onShowEmptyDetail: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 상단 영역: 제목과 더보기 버튼
            HStack {
                Text("지난 경로") 
                    .font(.custom("Pretendard-SemiBold", size: 18))
                Spacer()
                Button("더보기") {
                    if let walk = viewModel.recentWalk {
                        // startedAt(String) -> Date 변환
                        if let date = Self.parseDate(from: walk.startedAt) {
                            onShowDetail?(date)
                        }
                    } else {
                        onShowEmptyDetail?()
                    }
                }
                .font(.custom("Pretendard-Regular", size: 14))
                .fontWeight(.light)
                .foregroundColor(Color("gray800"))
            }
            .padding(.bottom, 5)

            // 콘텐츠 영역 (지도와 산책 정보)
            WalkRouteSummaryView(
                coordinates: viewModel.getNaverMapCoordinates(),
                distance: viewModel.recentWalk != nil ? String(format: "%.2f", viewModel.recentWalk!.distanceKm) : "-",
                duration: viewModel.recentWalk != nil ? {
                    let mins = viewModel.recentWalk!.durationSec / 60
                    let secs = viewModel.recentWalk!.durationSec % 60
                    return String(format: "%d:%02d", mins, secs)
                }() : "-",
                calories: viewModel.recentWalk != nil ? "\(viewModel.recentWalk!.calories)" : "-",
                isLoading: viewModel.isLoading,
                errorMessage: viewModel.errorMessage,
                emptyMessage: "최근 산책 기록이 없습니다",
                boundingBox: viewModel.calculateMapBounds()
            )
        }
        .cornerRadius(10)
    }
    // startedAt(String) -> Date 변환 함수
    private static func parseDate(from startedAt: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.date(from: startedAt)
    }
}

#Preview {
    PastRoutesView()
        .padding()
}

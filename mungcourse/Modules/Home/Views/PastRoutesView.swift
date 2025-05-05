import SwiftUI
import UIKit
import NMapsGeometry

struct PastRoutesView: View {
    @StateObject private var viewModel = PastRoutesViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 상단 영역: 제목과 더보기 버튼
            HStack {
                Text("지난 경로") 
                    .font(.custom("Pretendard-SemiBold", size: 18))
                Spacer()
                Button("더보기") {
                    // TODO: 더보기 액션 구현
                    print("과거 산책 기록 더보기 탭됨")
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
}

#Preview {
    PastRoutesView()
        .padding()
}

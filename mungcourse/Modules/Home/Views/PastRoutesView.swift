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
            ZStack(alignment: .topLeading) {
                // 상태에 따른 뷰
                Group {
                    if viewModel.isLoading {
                        loadingView
                    } else if let errorMessage = viewModel.errorMessage {
                        errorView(message: errorMessage)
                    } else if viewModel.recentWalk == nil {
                        noDataView
                    } else {
                        mapContentView
                    }
                }
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            // 최근 산책 정보 표시
            if let walk = viewModel.recentWalk {
                WalkStatsBar(
                    distance: String(format: "%.2f", walk.distanceKm),
                    duration: {
                        let mins = walk.durationSec / 60
                        let secs = walk.durationSec % 60
                        return String(format: "%d:%02d", mins, secs)
                    }(),
                    calories: "\(walk.calories)",
                    isActive: false
                )
            }
        }
        .cornerRadius(10)
    }
    
    // MARK: - 서브뷰
    
    // 로딩 뷰
    private var loadingView: some View {
        ZStack {
            Color("gray200")
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.2)
        }
    }
    
    // 에러 뷰
    private func errorView(message: String) -> some View {
        ZStack {
            Color("gray200")
            VStack {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 24))
                    .foregroundColor(.orange)
                Text("산책 기록을 불러올 수 없습니다")
                    .font(.custom("Pretendard-Medium", size: 16))
                    .padding(.top, 4)
                Text(message)
                    .font(.custom("Pretendard-Regular", size: 12))
                    .foregroundColor(Color("gray600"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    // 데이터 없음 뷰
    private var noDataView: some View {
        ZStack {
            Color("gray200")
            VStack {
                Image(systemName: "figure.walk")
                    .font(.system(size: 24))
                    .foregroundColor(Color("gray600"))
                Text("최근 산책 기록이 없습니다")
                    .font(.custom("Pretendard-Medium", size: 16))
                    .padding(.top, 4)
                Text("산책을 시작해보세요!")
                    .font(.custom("Pretendard-Regular", size: 14))
                    .foregroundColor(Color("gray600"))
            }
        }
    }
    
    // 지도 콘텐츠 뷰
    private var mapContentView: some View {
        SimpleNaverMapView(
            coordinates: viewModel.getNaverMapCoordinates(),
            boundingBox: viewModel.calculateMapBounds(),
            pathColor: UIColor(named: "main")!,
            pathWidth: 5.0
        )
    }
    
    // 산책 정보 뷰
    private func walkInfoView(_ walk: Walk) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(walk.formattedDate)
                .font(.custom("Pretendard-Medium", size: 12))
                .foregroundColor(.white)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.black.opacity(0.6))
                .cornerRadius(4)
            
            HStack(spacing: 8) {
                Label(walk.formattedDistance, systemImage: "figure.walk")
                    .font(.custom("Pretendard-Regular", size: 12))
                    .foregroundColor(.white)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
                    .background(Color.blue.opacity(0.7))
                    .cornerRadius(4)
                
                Label(walk.formattedDuration, systemImage: "clock")
                    .font(.custom("Pretendard-Regular", size: 12))
                    .foregroundColor(.white)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
                    .background(Color.green.opacity(0.7))
                    .cornerRadius(4)
            }
        }
        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    PastRoutesView()
        .padding()
}

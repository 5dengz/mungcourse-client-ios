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
    // startedAt(String) -> Date 변환 함수 (ISO8601 및 기본 형식 처리)
    private static func parseDate(from startedAt: String) -> Date? {
        // ISO8601 형식(소수 초 포함) 파싱 시도
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: startedAt) {
            return date
        }
        // 기본 형식(초 단위) 파싱
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "ko_KR")
        if let date = formatter.date(from: startedAt) {
            return date
        }
        // 마지막 대안: ISO8601DateFormatter 기본 옵션
        let fallbackFormatter = ISO8601DateFormatter()
        if let date = fallbackFormatter.date(from: startedAt) {
            return date
        }
        return nil
    }
}

#Preview {
    PastRoutesView()
        .padding()
}

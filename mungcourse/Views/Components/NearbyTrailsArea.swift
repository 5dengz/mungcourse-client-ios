import SwiftUI

struct NearbyTrailsArea: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) { // 전체 VStack, 정렬 및 간격 설정
            // 상단 영역: 제목과 더보기 버튼
            HStack {
                Text("주변 산책로") // 제목
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Button("더보기") {
                    // TODO: 더보기 액션 구현
                    print("주변 산책로 더보기 탭됨")
                }
                .font(.callout)
                .foregroundColor(.gray)
            }
            .padding(.bottom, 5)

            // 콘텐츠 영역 (기존 가로 스크롤 뷰)
            // TODO: 실제 주변 산책로 데이터 연동 및 UI 구현 필요
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(0..<5) { _ in // 임시 데이터
                        VStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 120, height: 80)
                            Text("산책로 이름")
                                .font(.caption)
                            Text("거리 정보")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1)) // 배경색 약간 추가
        .cornerRadius(10)
    }
}

#Preview {
    NearbyTrailsArea()
        .padding() // 미리보기에서도 패딩 적용
}

import SwiftUI

struct NearbyTrailsArea: View {
    var body: some View {
        // TODO: 실제 주변 산책로 데이터 연동 및 UI 구현 필요
        VStack(alignment: .leading) {
            Text("주변 산책로")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 5)

            // 예시: 가로 스크롤 뷰 또는 리스트 형태
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

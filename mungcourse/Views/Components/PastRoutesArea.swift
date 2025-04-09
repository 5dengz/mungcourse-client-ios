import SwiftUI

struct PastRoutesArea: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) { // 전체 VStack, 정렬 및 간격 설정
            // 상단 영역: 제목과 더보기 버튼
            HStack {
                Text("지난 경로") 
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Button("더보기") {
                    // TODO: 더보기 액션 구현
                    print("과거 산책 기록 더보기 탭됨")
                }
                .font(.custom("Pretendard", size: 14)) // 더보기 버튼 폰트 크기 조절
                .fontWeight(.light)
                .foregroundColor(.gray)
            }
            .padding(.bottom, 5)

            // 콘텐츠 영역 (기존 리스트)
            // TODO: 실제 지난 경로 데이터 연동 및 UI 구현 필요
            VStack(spacing: 10) {
                ForEach(0..<3) { index in // 임시 데이터
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 50, height: 50)
                        VStack(alignment: .leading) {
                            Text("경로 \(index + 1) - 날짜 정보")
                                .font(.headline)
                            Text("거리, 시간 등 요약 정보")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                    if index < 2 { // 마지막 항목 제외하고 구분선 추가
                        Divider()
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
    PastRoutesArea()
        .padding() // 미리보기에서도 패딩 적용
}

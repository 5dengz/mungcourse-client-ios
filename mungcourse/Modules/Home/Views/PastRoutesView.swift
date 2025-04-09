import SwiftUI

struct PastRoutesView: View { // <- 이름 변경
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

            // 콘텐츠 영역 (지도 표시 영역으로 변경)
            ZStack(alignment: .topLeading) { // 지도 배경과 시간 뷰를 겹치기 위한 ZStack
                // 지도 API 연동 전 임시 배경 (둥근 모서리 사각형)
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2)) // 연한 회색 배경
                    .frame(height: 150) // 임시 높이 설정

                // 왕복 시간 뷰 추가 (임시 데이터)
                RoundTripTimeView(timeString: "약 1시간 5분")
                    .padding(8) // 가장자리로부터 여백
            }
        }
        //.padding() // 전체 영역 패딩 제거됨
        .cornerRadius(10)
    }
}

#Preview {
    PastRoutesView() // <- 이름 변경
        .padding() // 미리보기에서도 패딩 적용
}

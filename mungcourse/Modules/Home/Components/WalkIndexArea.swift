import SwiftUI

struct WalkIndexArea: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) { // 전체를 VStack으로 감싸고 정렬 및 간격 설정
            // 상단 영역: 제목과 더보기 버튼
            HStack {
                Text("산책 지수") // 제목
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer() // 제목과 버튼 사이 공간 최대화
                Button("더보기") {
                    // TODO: 더보기 액션 구현
                    print("산책 지수 더보기 탭됨")
                }
                .font(.callout) // 더보기 버튼 폰트 크기 조절
                .foregroundColor(.gray) // 더보기 버튼 색상
            }
            .padding(.bottom, 5) // 상단 영역과 콘텐츠 영역 사이 간격

            // 콘텐츠 영역 (기존 내용)
            // TODO: 실제 산책 지수 데이터 연동 및 UI 구현 필요
            Text("산책 지수 콘텐츠 영역") // 임시 텍스트 수정
                .frame(maxWidth: .infinity, minHeight: 80) // 높이 조절
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8) // 코너 라운딩 약간 줄임
        }
        //.padding() // 전체 컴포넌트에 패딩 적용
        .cornerRadius(10)
    }
}

#Preview {
    WalkIndexArea()
        .padding()
}

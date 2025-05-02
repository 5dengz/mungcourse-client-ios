import SwiftUI

// TrailItemView는 이제 별도 파일(Components/TrailItemView.swift)에 정의되어 있습니다.

struct NearbyTrailsView: View { // <- 이름 변경
    // 임시 산책로 데이터 배열 - 실제 데이터로 교체 필요
    let sampleTrails = [
        // roundTripTime 파라미터 추가
        TrailItemView(trailName: "올림픽공원", distance: "1.2km", imageName: "", roundTripTime: "약 25분"),
        TrailItemView(trailName: "서울숲", distance: "2.5km", imageName: "", roundTripTime: "약 50분"),
        TrailItemView(trailName: "남산 둘레길", distance: "3.0km", imageName: "", roundTripTime: "약 1시간"),
        TrailItemView(trailName: "한강공원 잠실", distance: "0.8km", imageName: "", roundTripTime: "약 15분"),
        TrailItemView(trailName: "석촌호수", distance: "1.5km", imageName: "", roundTripTime: "약 30분")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) { // 전체 VStack, 정렬 및 간격 설정
            // 상단 영역: 제목과 더보기 버튼
            HStack {
                Text("주변 산책로") // 제목
                    .font(.custom("Pretendard-SemiBold", size: 18))
                Spacer()
                Button("더보기") {
                    // TODO: 더보기 액션 구현
                    print("주변 산책로 더보기 탭됨")
                }
                .font(.custom("Pretendard-Regular", size: 14))
                .foregroundColor(Color("gray800"))
            }
            .padding(.bottom, 5)

            // 콘텐츠 영역: 새로운 TrailItemView 사용
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) { // 아이템 간 간격
                    ForEach(sampleTrails, id: \.trailName) { trail in // 고유 식별자 주의 (실제 데이터 모델 사용 시 id 활용)
                        trail // TrailItemView 인스턴스 바로 사용
                    }
                }
                .padding(.vertical, 5) // 스크롤 뷰 내부 상하 패딩
            }
        }
        //.padding() // 전체 영역 패딩
        .cornerRadius(10)
    }
}

#Preview {
    NearbyTrailsView() // <- 이름 변경
        .padding() // 미리보기에서도 패딩 적용
}

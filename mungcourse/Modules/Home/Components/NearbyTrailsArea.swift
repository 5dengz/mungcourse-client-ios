import SwiftUI

// 단일 산책로 아이템 뷰
struct TrailItemView: View {
    // 임시 데이터 - 실제 데이터 모델로 교체 필요
    let trailName: String
    let distance: String
    let imageName: String // 이미지 이름 또는 URL

    var body: some View {
        VStack(alignment: .leading, spacing: 8) { // 아이템 전체 컨테이너
            // 1. 사진 영역
            Image(imageName) // 시스템 이미지 또는 Assets 이미지 사용
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 210, height: 150) // 크기 조절 <- 복원됨
                .clipShape(RoundedRectangle(cornerRadius: 10)) // 모서리 둥글게
                .overlay( // 이미지 없을 경우 대비 회색 배경
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 210, height: 150) // <- 복원됨
                        .opacity(imageName.isEmpty ? 1 : 0) // 이미지가 있으면 투명하게
                )


            // 2. 정보 영역 (이름 + 거리)
            HStack {
                Text(trailName)
                    .font(.system(size: 14)) // 이름 폰트 크기 14
                    .lineLimit(1) // 한 줄로 제한
                    .fontWeight(.semibold) // 이름 폰트 두께
                Spacer() // 이름과 거리 사이 공간
                Text(distance)
                    .font(.system(size: 14)) // 거리 폰트 크기 14
                    .fontWeight(.semibold)
                    
            }
            .frame(width: 210) // HStack 너비 고정 (이미지 너비와 맞춤)
            .padding(.vertical, 10) // 좌우 패딩

            // 3. 산책 시작 버튼
            Button {
                // TODO: 산책 시작 액션 구현
                print("\(trailName) 산책 시작")
            } label: {
                Text("산책 시작")
                    .font(.caption)
                    .fontWeight(.regular)
                    .foregroundColor(.black)
                    // .frame(maxWidth: .infinity) // 너비 최대로 확장 <- 제거
                    .frame(width: 211, height: 36) // 고정 크기 설정
                    .background(Color.gray.opacity(0.1)) // 버튼 배경색
                    .cornerRadius(8)
            }
            // 버튼을 VStack 내에서 중앙 정렬하거나 leading 정렬할 수 있음
            // .frame(maxWidth: .infinity, alignment: .center) // 중앙 정렬 예시
        }
        
        .background(Color.white) // 아이템 배경색
        .cornerRadius(15) // 아이템 모서리 둥글게
    }
}


struct NearbyTrailsArea: View {
    // 임시 산책로 데이터 배열 - 실제 데이터로 교체 필요
    let sampleTrails = [
        TrailItemView(trailName: "올림픽공원", distance: "1.2km", imageName: ""), // 이미지 이름 비워두면 회색 배경
        TrailItemView(trailName: "서울숲", distance: "2.5km", imageName: ""), // SF Symbol 사용 예시
        TrailItemView(trailName: "남산 둘레길", distance: "3.0km", imageName: ""),
        TrailItemView(trailName: "한강공원 잠실", distance: "0.8km", imageName: ""), // SF Symbol 사용 예시
        TrailItemView(trailName: "석촌호수", distance: "1.5km", imageName: "")
    ]

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
    NearbyTrailsArea()
        .padding() // 미리보기에서도 패딩 적용
}

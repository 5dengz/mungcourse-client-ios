import SwiftUI

// 단일 산책로 아이템 뷰
struct TrailItemView: View {
    // 임시 데이터 - 실제 데이터 모델로 교체 필요
    let trailName: String
    let distance: String
    let imageName: String // 이미지 이름 또는 URL
    let roundTripTime: String // 왕복 시간 추가 (예: "약 30분")

    var body: some View {
        VStack(alignment: .leading, spacing: 8) { // 아이템 전체 컨테이너
            // 1. 사진 영역 (ZStack으로 변경)
            ZStack(alignment: .topLeading) { // 이미지와 시간 뷰를 겹치기 위한 ZStack
                Image(imageName) // 시스템 이미지 또는 Assets 이미지 사용
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 210, height: 150) // 크기 조절
                    .clipShape(RoundedRectangle(cornerRadius: 10)) // 모서리 둥글게
                    .overlay( // 이미지 없을 경우 대비 회색 배경
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 210, height: 150)
                            .opacity(imageName.isEmpty ? 1 : 0) // 이미지가 있으면 투명하게
                    )

                // 왕복 시간 뷰 추가
                RoundTripTimeView(timeString: roundTripTime)
                    .padding(8) // 이미지 가장자리로부터 약간의 여백
            }


            // 2. 정보 영역 (이름 + 거리)
            HStack {
                Text(trailName)
                    .font(.system(size: 14)) // 이름 폰트 크기 14
                    .lineLimit(1) // 한 줄로 제한
                    .fontWeight(.semibold) // 이름 폰트 두께
                Spacer() // 이름과 거리+아이콘 그룹 사이 공간
                HStack(spacing: 2) { // 아이콘과 거리 텍스트 사이 간격 조절
                    Image("pinpoint") // pinpoint 아이콘 추가
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15) // 아이콘 크기 조절
                    Text(distance)
                        .font(.system(size: 14)) // 거리 폰트 크기 14
                        .fontWeight(.semibold)
                }
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
                    .frame(width: 211, height: 36) // 고정 크기 설정
                    .background(Color.gray.opacity(0.1)) // 버튼 배경색
                    .cornerRadius(8)
            }
        }

        .background(Color.white) // 아이템 배경색
        //.cornerRadius(15) // 아이템 모서리 둥글게
    }
}

#Preview {
    // roundTripTime 파라미터 추가
    TrailItemView(trailName: "샘플 산책로", distance: "1.5km", imageName: "", roundTripTime: "약 45분")
        .padding()
}

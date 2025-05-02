import SwiftUI

// 단일 산책로 아이템 뷰
struct TrailItemView: View {
    // 데이터 모델
    let trailName: String
    let distance: String
    let imageName: String // 이미지 이름 또는 URL
    let roundTripTime: String // 왕복 시간 (NearbyTrailsView에서 openingHours 사용 중)
    let category: String // 카테고리 파라미터 추가

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // spacing 0으로 변경
            // 1. 사진 영역
            ZStack(alignment: .topLeading) {
                if let url = URL(string: imageName), !imageName.isEmpty {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 210, height: 146)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 210, height: 146)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                        )
                }

                // 왕복 시간 뷰 복원
                if !roundTripTime.isEmpty { // 시간이 비어있지 않을 때만 표시
                    RoundTripTimeView(timeString: roundTripTime)
                        .padding(8)
                }
            }

            // 2. 정보 영역 (VStack + HStack)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(trailName)
                        .font(.custom("Pretendard-SemiBold", size: 15))
                        .lineLimit(1)
                    Spacer()
                    HStack(spacing: 2) {
                        Image("pinpoint")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                        Text(distance)
                            .font(.custom("Pretendard-Regular", size: 12))
                    }
                }
                
                Text(category)
                    .font(.custom("Pretendard-Regular", size: 12))
                    .foregroundColor(Color("gray700"))
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(width: 210, height: 66)
        }
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color("gray300"), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    // roundTripTime 파라미터 복원
    TrailItemView(trailName: "샘플 산책로 이름", distance: "1.5km", imageName: "", roundTripTime: "약 45분", category: "공원")
        .padding()
}

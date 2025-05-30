import SwiftUI

struct OnboardingPageView: View {
    let mainTitle: String
    let subTitle: String
    let imageName: String
    
    var body: some View {
        ZStack(alignment: .center) {
            // 배경 이미지
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 310, height: 575)
                .frame(maxWidth: .infinity) // 좌우 너비 기준 중간에 배치
            
            // 텍스트 콘텐츠 (인디케이터보다 44 위에 위치)
            VStack(spacing: 16) {
                Text(mainTitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text(subTitle)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
            }
            .padding(.horizontal)
            .padding(.bottom, 44) // 인디케이터로부터 44만큼 위에 위치
            .padding(.horizontal, 20)
            .frame(maxHeight: .infinity, alignment: .bottom) // 텍스트는 여전히 하단에 위치
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    OnboardingPageView(
        mainTitle: "AI 기반 코스 추천",
        subTitle: "소중한 반려견에게 위험한 요소를 피해,\n안전한 산책 코스를 추천해줘요",
        imageName: "Image1"
    )
}

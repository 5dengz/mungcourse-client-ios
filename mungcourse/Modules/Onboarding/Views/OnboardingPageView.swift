import SwiftUI

struct OnboardingPageView: View {
    let mainTitle: String
    let subTitle: String
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer() // 상단에 여백을 추가하여 컨텐츠를 하단으로 밀어냄
            
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
        .padding()
    }
}

#Preview {
    OnboardingPageView(
        mainTitle: "AI 기반 코스 추천",
        subTitle: "소중한 반려견에게 위험한 요소를 피해, 안전한 산책 코스를 추천해줘요"
    )
}

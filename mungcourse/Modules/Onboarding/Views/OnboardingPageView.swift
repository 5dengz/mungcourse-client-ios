import SwiftUI

struct OnboardingPageView: View {
    let mainTitle: String
    let subTitle: String
    let imageName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
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
            
            Spacer()
            
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.bottom, 35)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    OnboardingPageView(
        mainTitle: "AI 기반 코스 추천",
        subTitle: "소중한 반려견에게 위험한 요소를 피해,\n안전한 산책 코스를 추천해줘요",
        imageName: "Image1"
    )
}

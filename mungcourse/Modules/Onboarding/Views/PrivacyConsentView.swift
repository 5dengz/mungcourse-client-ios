import SwiftUI

struct PrivacyConsentView: View {
    let onAccept: () -> Void
    
    // 임시 개인정보 처리 방침 텍스트
    private let privacyPolicyText = "멍코스 앱은 사용자의 개인정보를 안전하게 보호하며, 다음과 같은 정보를 수집합니다.\n\n1. 위치 정보: 앱에서 코스 추천 및 지도 기능 제공을 위해 위치 정보를 사용합니다.\n2. 닉네임 및 프로필 정보: 사용자 식별 및 맞춤형 서비스를 위해 사용됩니다.\n3. 쿠키 및 로그 데이터: 서비스 최적화 및 문제 해결을 위해 수집될 수 있습니다.\n\n수집된 개인정보는 맹목적으로 제3자에게 제공되지 않으며, 사용자가 동의하지 않을 경우 서비스 이용 제한이 있을 수 있습니다.\n\n자세한 내용은 앱 내 설정에서 확인하실 수 있습니다."
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color("gray100").ignoresSafeArea()
            VStack(spacing: 20) {
                Spacer()
                Text("개인정보 보호 동의")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                ScrollView {
                    Text(privacyPolicyText)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 30)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxHeight: 300)
                CommonFilledButton(
                    title: "수락",
                    action: onAccept
                )
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    PrivacyConsentView(onAccept: { })
}
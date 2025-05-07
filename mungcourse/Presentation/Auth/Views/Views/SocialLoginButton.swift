import SwiftUI

struct SocialLoginButton<Icon: View>: View {
    let icon: () -> Icon
    let text: String
    let textColor: Color
    let backgroundColor: Color
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // 텍스트는 버튼 전체 기준 중앙 정렬
                Text(text)
                    .font(.headline)
                    .foregroundColor(textColor)
                    .frame(maxWidth: .infinity, alignment: .center)
                // 아이콘은 좌측 끝에 고정
                HStack {
                    icon()
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                ZStack {
                    // 배경색
                    backgroundColor
                    // 조건부 stroke
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            backgroundColor == Color("pointwhite") ? Color("gray400") : backgroundColor,
                            lineWidth: 1
                        )
                }
            )
            .cornerRadius(28)
        }
        .disabled(isLoading)
    }
}

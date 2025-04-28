import SwiftUI

struct SocialLoginButton: View {
    let icon: Image
    let text: String
    let textColor: Color
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                icon
                
                Text(text)
                    .font(.headline)
                    .foregroundColor(textColor)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
        }
        .disabled(isLoading)
    }
}

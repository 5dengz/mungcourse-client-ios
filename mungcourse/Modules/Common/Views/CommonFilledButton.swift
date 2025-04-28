import SwiftUI

struct CommonFilledButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var backgroundColor: Color = Color.main
    var foregroundColor: Color = .white
    var cornerRadius: CGFloat = 10
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isEnabled ? backgroundColor : Color.gray.opacity(0.3))
                .cornerRadius(cornerRadius)
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    VStack(spacing: 20) {
        CommonFilledButton(title: "활성화 버튼", action: {})
        CommonFilledButton(title: "비활성화 버튼", action: {}, isEnabled: false)
    }
    .padding()
}

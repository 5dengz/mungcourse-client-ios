import SwiftUI

struct InputBoxStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .frame(height: 41)
            .background(Color.white) // Or slightly off-white if needed
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("gray300"), lineWidth: 0.5) // Use asset color
            )
    }
}

// Extension to make applying the modifier easier
extension View {
    func inputBoxStyle() -> some View {
        self.modifier(InputBoxStyle())
    }
}

#Preview {
    Text("스타일 적용 예시")
        .inputBoxStyle()
        .padding()
} 
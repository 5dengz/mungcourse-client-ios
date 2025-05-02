import SwiftUI

// --- Specific Input Field Types ---

struct RequiredTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        InputFieldContainer(title: title) {
            TextField(placeholder, text: $text)
                .font(.custom("Pretendard-Regular", size: 14))
                .inputBoxStyle() // Use the extension method
                .foregroundColor(text.isEmpty ? Color("gray500") : Color("black")) // Placeholder color
        }
    }
}

#Preview {
    // Use PreviewWrapper for @State management
    struct PreviewWrapper: View {
        @State var sampleText: String = ""
        
        var body: some View {
            RequiredTextField(title: "필수 텍스트", placeholder: "입력하세요", text: $sampleText)
                .padding()
        }
    }
    return PreviewWrapper()
} 
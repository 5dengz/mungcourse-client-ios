import SwiftUI

// --- Base Input Field Style ---
struct InputFieldContainer<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Pretendard-SemiBold", size: 16))
                .foregroundColor(Color("gray800")) // Use asset color
            content
        }
    }
}

#Preview {
    InputFieldContainer(title: "샘플 제목") {
        Text("여기에 컨텐츠가 들어갑니다")
            .padding()
            .background(Color.yellow.opacity(0.3))
    }
    .padding()
} 
import SwiftUI

struct WalkCompleteFeedbackModal: View {
    @Binding var isPresented: Bool
    @State private var selected: Int = 0
    var onComplete: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 28) {
            VStack(spacing: 8) {
                Text("오늘 추천 코스 만족스러우셨나요?")
                    .font(.custom("Pretendard", size: 18).weight(.semibold))
                    .foregroundColor(Color("black"))
                Text("이 피드백은 다음 산책 코스 추천에 반영돼요")
                    .font(.custom("Pretendard", size: 14))
                    .foregroundColor(Color("gray600"))
            }
            HStack(spacing: 18) {
                ForEach(1...5, id: \.self) { idx in
                    Image(selected >= idx ? "star_filled" : "star_empty")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .onTapGesture { selected = idx }
                }
            }
            CommonFilledButton(title: "완료", action: {
                isPresented = false
                onComplete?()
            })
            .padding(.top, 8)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .shadow(color: Color("black10").opacity(0.12), radius: 16, x: 0, y: 8)
        .frame(maxWidth: 360)
    }
}

#Preview {
    WalkCompleteFeedbackModal(isPresented: .constant(true))
}

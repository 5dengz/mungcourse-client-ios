import SwiftUI

struct StartWalkTabView: View {
    @Binding var isOverlayPresented: Bool
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                CommonFilledButton(
                    title: "경유지 선택",
                    action: { isOverlayPresented = false },
                    backgroundColor: .white,
                    foregroundColor: Color("main"),
                    cornerRadius: 12
                )
                .font(.custom("Pretendard-SemiBold", size: 18))
                CommonFilledButton(
                    title: "바로 추천",
                    action: { isOverlayPresented = false },
                    backgroundColor: Color("main"),
                    foregroundColor: .white,
                    cornerRadius: 12
                )
                .font(.custom("Pretendard-SemiBold", size: 18))
            }
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    StartWalkTabView(isOverlayPresented: .constant(true))
}

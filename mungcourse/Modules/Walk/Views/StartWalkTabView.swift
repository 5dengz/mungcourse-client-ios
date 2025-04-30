import SwiftUI

struct StartWalkTabView: View {
    @Binding var isOverlayPresented: Bool
    let onSelectWaypoint: () -> Void
    let onRecommendCourse: () -> Void
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    isOverlayPresented = false
                }
            VStack(spacing: 16) {
                CommonFilledButton(
                    title: "경유지 선택",
                    action: {
                        onSelectWaypoint()
                        isOverlayPresented = false
                    },
                    backgroundColor: .white,
                    foregroundColor: Color("main"),
                    cornerRadius: 12
                )
                .font(.custom("Pretendard-SemiBold", size: 18))
                CommonFilledButton(
                    title: "바로 추천",
                    action: {
                        onRecommendCourse()
                        isOverlayPresented = false
                    },
                    backgroundColor: Color("main"),
                    foregroundColor: .white,
                    cornerRadius: 12
                )
                .font(.custom("Pretendard-SemiBold", size: 18))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32 + 56) // 탭바 높이(56) + 여유
        }
    }
}

#Preview {
    NavigationStack {
        StartWalkTabView(
            isOverlayPresented: .constant(true),
            onSelectWaypoint: { },
            onRecommendCourse: { }
        )
    }
}

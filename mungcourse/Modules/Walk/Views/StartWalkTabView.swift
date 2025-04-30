import SwiftUI

struct StartWalkTabView: View {
    @Binding var isOverlayPresented: Bool
    @State private var showSelectWaypoint = false
    @State private var showRecommendCourse = false
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                CommonFilledButton(
                    title: "경유지 선택",
                    action: {
                        showSelectWaypoint = true
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
                        showRecommendCourse = true
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
            // 네비게이션 연결
            .background(
                NavigationLink(destination: SelectWaypointView(), isActive: $showSelectWaypoint) { EmptyView() }
                    .hidden()
            )
            .background(
                NavigationLink(destination: RecommendCourseView(), isActive: $showRecommendCourse) { EmptyView() }
                    .hidden()
            )
        }
    }
}

#Preview {
    NavigationStack {
        StartWalkTabView(isOverlayPresented: .constant(true))
    }
}

import SwiftUI

struct StartWalkTabView: View {
    var onSelectWaypoint: () -> Void
    var onRecommendCourse: () -> Void
    var onDismiss: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            Text("산책 시작 방식")
                .font(.custom("Pretendard-SemiBold", size: 18))
                .padding(.top, 36)
            
            CommonFilledButton(
                title: "경유지 선택",
                action: {
                    onSelectWaypoint()
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
                },
                backgroundColor: Color("main"),
                foregroundColor: .white,
                cornerRadius: 12
            )
            .font(.custom("Pretendard-SemiBold", size: 18))
            
            Spacer()
        }
        .padding(.horizontal, 32)
        .presentationDetents([.height(230)])
        .presentationCornerRadius(20)
        .onDisappear {
            onDismiss?()
        }
    }
}

#Preview {
    NavigationStack {
        StartWalkTabView(
            onSelectWaypoint: { },
            onRecommendCourse: { }
        )
    }
}

// 시트를 표시하기 위한 확장
extension View {
    func startWalkTabSheet(
        isPresented: Binding<Bool>,
        onSelectWaypoint: @escaping () -> Void,
        onRecommendCourse: @escaping () -> Void
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            StartWalkTabView(
                onSelectWaypoint: {
                    onSelectWaypoint()
                    isPresented.wrappedValue = false
                },
                onRecommendCourse: {
                    onRecommendCourse()
                    isPresented.wrappedValue = false
                },
                onDismiss: {
                    // 시트가 사라질 때 필요한 작업이 있다면 여기에 추가
                }
            )
        }
    }
}

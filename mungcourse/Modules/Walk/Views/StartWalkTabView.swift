import SwiftUI

struct StartWalkTabView: View {
    var onSelectWaypoint: () -> Void
    var onRecommendCourse: () -> Void
    var onDismiss: (() -> Void)? = nil
    @EnvironmentObject var dogVM: DogViewModel
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("산책 시작 방식")
                    .font(.custom("Pretendard-SemiBold", size: 18))
                    .padding(.top, 36)
                    .padding(.leading, 29)
                    .padding(.bottom, 15)
                
                NavigationLink(destination: StartWalkView(routeOption: nil).environmentObject(dogVM)) {
                    HStack {
                        Text("산책 시작")
                            .font(.custom("Pretendard-SemiBold", size: 18))
                            .foregroundColor(Color("main"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .background(Color("pointwhite"))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color("gray300"), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 29)
                
                CommonFilledButton(
                    title: "코스 선택",
                    action: {
                        onRecommendCourse()
                    },
                    backgroundColor: Color("main"),
                    foregroundColor: Color("pointwhite"),
                    cornerRadius: 12
                )
                .font(.custom("Pretendard-SemiBold", size: 18))
                .padding(.horizontal, 29)
                
                Spacer()
            }
            .presentationDetents([.height(230)])
            .presentationCornerRadius(20)
            .onDisappear {
                onDismiss?()
            }
        }
    }
}

#Preview {
    NavigationStack {
        StartWalkTabView(
            onSelectWaypoint: { },
            onRecommendCourse: { }
        )
        .environmentObject(DogViewModel())
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
            .environmentObject(DogViewModel())
        }
    }
}

import SwiftUI

struct RecommendCourseView: View {
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            CommonHeaderView(leftIcon: "arrow_back", leftAction: {
                onBack()
            }, title: "코스 추천")
            CommonSearchView()
            ScrollView {
                VStack {
                    Text("코스 추천 페이지")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    RecommendCourseView(onBack: {})
} 
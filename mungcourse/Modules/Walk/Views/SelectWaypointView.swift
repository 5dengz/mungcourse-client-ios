import SwiftUI

struct SelectWaypointView: View {
    var body: some View {
        VStack(spacing: 0) {
            CommonHeaderView(leftIcon: "arrow_back", leftAction: {
                // TODO: 뒤로 가기 기능 구현
            }, title: "경유지 선택")
            CommonSearchView()
                .padding(.vertical, 10)
            // 컨텐츠 영역 placeholder
            ScrollView {
                VStack {
                    Text("컨텐츠 영역")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}

#Preview {
    SelectWaypointView()
} 
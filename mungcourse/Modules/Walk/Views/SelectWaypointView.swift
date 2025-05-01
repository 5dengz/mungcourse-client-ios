import SwiftUI

struct SelectWaypointView: View {
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            CommonHeaderView(leftIcon: "arrow_back", leftAction: {
                onBack()
            }, title: "경유지 선택")
            CommonSearchView()
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
        .navigationBarHidden(true)
    }
}

#Preview {
    SelectWaypointView(onBack: { })
} 
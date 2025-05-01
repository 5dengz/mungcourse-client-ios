import SwiftUI

struct SelectWaypointView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            CommonHeaderView(leftIcon: "arrow_back", leftAction: {
                dismiss()
            }, title: "경유지 선택")
            CommonSearchView()
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
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
        .navigationBarHidden(true)
    }
}

#Preview {
    SelectWaypointView()
} 
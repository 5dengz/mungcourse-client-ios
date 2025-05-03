import SwiftUI

struct AccountDeletionView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            CommonHeaderView(
                leftIcon: "icon_x",
                leftAction: { dismiss() },
                title: "회원 탈퇴"
            )
            VStack(alignment: .leading, spacing: 16) {
                Text("탈퇴 이유를 알려주세요")
                    .font(.headline)
                    .padding()
            }
            .background(Color.white)
            Spacer()
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#if DEBUG
struct AccountDeletionView_Previews: PreviewProvider {
    static var previews: some View {
        AccountDeletionView()
    }
}
#endif 
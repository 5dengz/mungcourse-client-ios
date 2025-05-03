import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isNotificationsEnabled = false
    @State private var isWalkPushEnabled = false
    @State private var isStopPushEnabled = false

    var body: some View {
        VStack(spacing: 0) {
            CommonHeaderView(
                leftIcon: "icon_x",
                leftAction: { dismiss() },
                title: "알림 및 기능"
            )
            VStack(spacing: 1) {
                Toggle("알림 활성화", isOn: $isNotificationsEnabled)
                    .padding()
                    .background(Color.white)
                Divider()
                Toggle("산책 푸시 알림", isOn: $isWalkPushEnabled)
                    .padding()
                    .background(Color.white)
                Divider()
                Toggle("산책 중단 알림", isOn: $isStopPushEnabled)
                    .padding()
                    .background(Color.white)
            }
            .background(Color(UIColor.systemGroupedBackground))
            Spacer()
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#if DEBUG
struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
    }
}
#endif 
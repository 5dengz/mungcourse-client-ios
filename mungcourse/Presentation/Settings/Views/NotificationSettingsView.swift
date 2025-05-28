import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isNotificationsEnabled = false
    @State private var isWalkPushEnabled = false
    @State private var isStopPushEnabled = false

    var body: some View {
        VStack(spacing: 0) {
            CommonHeaderView(
                leftIcon: "arrow_back",
                leftAction: { dismiss() },
                title: "알림 및 기능"
            )
            .padding(.bottom, 28)
            VStack(spacing: 0) {
                HStack {
                    Text("알림 활성화")
                        .font(.custom("Pretendard-Regular", size: 16))
                        .foregroundColor(.black)
                    Spacer()
                    Toggle("", isOn: $isNotificationsEnabled)
                        .labelsHidden()
                }
                .padding(.horizontal, 16)
                .background(Color("pointwhite"))
                .padding(.bottom, 35)
                HStack {
                    Text("산책 푸시 알림")
                        .font(.custom("Pretendard-Regular", size: 16))
                        .foregroundColor(.black)
                    Spacer()
                    Toggle("", isOn: $isWalkPushEnabled)
                        .labelsHidden()
                }
                .padding(.horizontal, 16)
                .background(Color("pointwhite"))
                .padding(.bottom, 35)
                HStack {
                    Text("산책 중단 알림")
                        .font(.custom("Pretendard-Regular", size: 16))
                        .foregroundColor(.black)
                    Spacer()
                    Toggle("", isOn: $isStopPushEnabled)
                        .labelsHidden()
                }
                .padding(.horizontal, 16)
                .background(Color("pointwhite"))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
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
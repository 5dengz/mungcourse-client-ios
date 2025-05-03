import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CommonHeaderView(
                    leftIcon: "icon_x",
                    leftAction: { dismiss() },
                    title: "설정"
                )
                VStack(spacing: 1) {
                    NavigationLink(destination: NotificationSettingsView()) {
                        HStack {
                            Text("알림 및 기능")
                                .foregroundColor(.black)
                            Spacer()
                            Image("arrow_right")
                                .renderingMode(.template)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                    }
                    Divider()
                    Button(action: { /* 문의하기 액션 */ }) {
                        HStack {
                            Text("문의하기")
                                .foregroundColor(.black)
                            Spacer()
                            Image("arrow_right")
                                .renderingMode(.template)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                    }
                    Divider()
                    Button(action: { /* 이용약관 액션 */ }) {
                        HStack {
                            Text("이용약관")
                                .foregroundColor(.black)
                            Spacer()
                            Image("arrow_right")
                                .renderingMode(.template)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                    }
                    Divider()
                    NavigationLink(destination: AccountDeletionView()) {
                        HStack {
                            Text("회원 탈퇴")
                                .foregroundColor(.black)
                            Spacer()
                            Image("arrow_right")
                                .renderingMode(.template)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
                Spacer()
            }
            .navigationBarHidden(true)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif 
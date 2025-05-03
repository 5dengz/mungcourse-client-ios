import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
                CommonHeaderView(
                    leftIcon: "icon_x",
                    leftAction: { dismiss() },
                    title: "설정"
                )
                VStack(spacing: 0) {
                    NavigationLink(destination: NotificationSettingsView().navigationBarHidden(true)) {
                        HStack {
                            Text("알림 및 기능")
                                .font(.custom("Pretendard-Regular", size: 16))
                                .foregroundColor(.black)
                            Spacer()
                            Image("arrow_right")
                                .renderingMode(.template)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .padding(.bottom, 16)
                    }
                    Button(action: { /* 문의하기 액션 */ }) {
                        HStack {
                            Text("문의하기")
                                .font(.custom("Pretendard-Regular", size: 16))
                                .foregroundColor(.black)
                            Spacer()
                            Image("arrow_right")
                                .renderingMode(.template)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .padding(.bottom, 16)
                    }
                    Button(action: { /* 이용약관 액션 */ }) {
                        HStack {
                            Text("이용약관")
                                .font(.custom("Pretendard-Regular", size: 16))
                                .foregroundColor(.black)
                            Spacer()
                            Image("arrow_right")
                                .renderingMode(.template)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .padding(.bottom, 16)
                    }
                    NavigationLink(destination: AccountDeletionView()) {
                        HStack {
                            Text("회원 탈퇴")
                                .font(.custom("Pretendard-Regular", size: 16))
                                .foregroundColor(.black)
                            Spacer()
                            Image("arrow_right")
                                .renderingMode(.template)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .padding(.bottom, 16)
                    }
                    Button(action: {
                        AuthService.shared.logout()
                        dismiss()
                    }) {
                        HStack {
                            Text("로그아웃")
                                .font(.custom("Pretendard-Regular", size: 16))
                                .foregroundColor(.black)
                            Spacer()
                            Image("arrow_right")
                                .renderingMode(.template)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 16)
                        .background(Color.white)
                    }
                .background(Color(UIColor.systemGroupedBackground))
                Spacer()
            }
            .navigationBarHidden(true)
            .padding(.horizontal, 16)
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
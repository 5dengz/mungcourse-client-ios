import SwiftUI
import Combine

struct LoginView: View {
    // ViewModel 사용
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        VStack {
            Spacer()
            
            // 안내 문구
            VStack(spacing: 8) {
                Text("멍코스와 함께\n산책을 시작하세요!")
                    .font(Font.custom("Pretendard-SemiBold", size: 24))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                Text("안전 코스 추천부터 산책 기록까지")
                    .font(Font.custom("Pretendard-Regular", size: 16))
                    .foregroundColor(Color("gray600"))
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 32)
            
            // 로고 이미지
            Image("logo_login")
                .resizable()
                .scaledToFit()
                .frame(width: 393)
                .padding(.bottom, 50)
            
            Spacer()
            
            // 로그인 버튼들
            VStack(spacing: 16) {
                // 카카오 로그인 버튼
                // SocialLoginButton(
                //     icon: { Image( "sns_kakaotalk").foregroundColor(.black) },
                //     text: "카카오 로그인",
                //     textColor: .black,
                //     backgroundColor: .pointYellow,
                //     isLoading: viewModel.isLoading,
                //     action: { viewModel.loginWithKakao() }
                // )
                
                // 구글 로그인 버튼
                SocialLoginButton(
                    icon: { Image( "sns_google").foregroundColor(Color("pointblack")) },
                    text: "구글 로그인",
                    textColor: Color("pointblack"),
                    backgroundColor: Color("pointwhite"),
                    isLoading: viewModel.isLoading,
                    action: { viewModel.loginWithGoogle() }
                )
                
                // 애플 로그인 버튼
                SocialLoginButton(
                    icon: { Image( "sns_apple").foregroundColor(Color("pointwhite")) },
                    text: "애플 로그인",
                    textColor: Color("pointwhite"),
                    backgroundColor: Color("pointblack"),
                    isLoading: viewModel.isLoading,
                    action: { viewModel.loginWithApple() }
                )
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray100)
        .fullScreenCover(isPresented: $viewModel.needsDogRegistration) {
            RegisterDogView()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // 앱이 활성화될 때 로그인 상태 확인
                viewModel.checkLoginStatus()
            }
        }
        .alert(item: $viewModel.errorMessage) { _ in
            Alert(
                title: Text("로그인 실패"),
                message: Text("다시 시도해주세요."),
                dismissButton: .default(Text("확인"))
            )
        }
    }
}

#Preview {
    LoginView()
}

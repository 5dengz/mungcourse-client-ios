import SwiftUI
import Combine

struct LoginView: View {
    // ViewModel 사용
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            
            // 안내 문구
            VStack(spacing: 8) {
                Text("멍코스와 함께\n산책을 시작하세요!")
                    .font(Font.custom("Pretendard", size: 24))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                Text("안전 코스 추천부터 산책 기록까지")
                    .font(Font.custom("Pretendard-Medium", size: 16))
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
                SocialLoginButton(
                    icon: { Image( "sns_kakaotalk").foregroundColor(.black) },
                    text: "카카오 로그인",
                    textColor: .black,
                    backgroundColor: .pointYellow,
                    isLoading: viewModel.isLoading,
                    action: { viewModel.loginWithApple() }
                )
                
                // 구글 로그인 버튼
                SocialLoginButton(
                    icon: { Image( "sns_google").foregroundColor(.black) },
                    text: "구글 로그인",
                    textColor: .black,
                    backgroundColor: .white,
                    isLoading: viewModel.isLoading,
                    action: { viewModel.loginWithGoogle() }
                )
                
                // 애플 로그인 버튼
                SocialLoginButton(
                    icon: { Image( "sns_apple").foregroundColor(.white) },
                    text: "애플 로그인",
                    textColor: .white,
                    backgroundColor: .black,
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
            RegisterDogView(viewModel: viewModel)
        }
    }
}

#Preview {
    LoginView()
}

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
                    .font(Font.custom("Pretendard-SemiBold", size: 24))
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
                // 구글 로그인 버튼
                SocialLoginButton(
                    icon: Image(systemName: "globe").foregroundColor(.black),
                    text: "구글 로그인",
                    textColor: .black,
                    backgroundColor: .white,
                    cornerRadius: 28,
                    isLoading: viewModel.isLoading,
                    action: { viewModel.loginWithGoogle() }
                )
                
                // 애플 로그인 버튼
                SocialLoginButton(
                    icon: Image(systemName: "apple.logo").foregroundColor(.white),
                    text: "애플 로그인",
                    textColor: .white,
                    backgroundColor: .black,
                    cornerRadius: 28,
                    isLoading: viewModel.isLoading,
                    action: { viewModel.loginWithApple() }
                )
                
                // 로딩 인디케이터
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.5)
                        .padding(.top, 10)
                }
                
                // 오류 메시지
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

#Preview {
    LoginView()
}

import SwiftUI
import Combine

struct LoginView: View {
    // ViewModel 사용
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            
            // 로고 이미지
            Image("logo_login")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(.bottom, 50)
            
            Spacer()
            
            // 로그인 버튼들
            VStack(spacing: 16) {
                // 구글 로그인 버튼
                Button(action: {
                    viewModel.loginWithGoogle()
                }) {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.black)
                        
                        Text("Google로 로그인")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                }
                .disabled(viewModel.isLoading)
                
                // 애플 로그인 버튼
                Button(action: {
                    viewModel.loginWithApple()
                }) {
                    HStack {
                        Image(systemName: "apple.logo")
                            .foregroundColor(.white)
                        
                        Text("Apple로 로그인")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                }
                .disabled(viewModel.isLoading)
                
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

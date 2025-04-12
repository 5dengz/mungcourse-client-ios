import SwiftUI

struct LoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("authToken") private var authToken: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            // 로그인 버튼들
            VStack(spacing: 16) {
                // 카카오 로그인 버튼
                Button(action: {
                    // 카카오 로그인 처리 (추후 구현)
                    performKakaoLogin()
                }) {
                    HStack {
                        Image(systemName: "message.fill")
                            .foregroundColor(.black)
                        
                        Text("카카오 로그인")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(10)
                }
                
                // 애플 로그인 버튼
                Button(action: {
                    // 애플 로그인 처리 (추후 구현)
                    performAppleLogin()
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
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
    }
    
    // 카카오 로그인 함수 (추후 실제 구현)
    private func performKakaoLogin() {
        print("카카오 로그인 시도")
        // 실제 로그인 구현 시 이 부분에 코드 추가
        // 로그인 API 호출하여 토큰 받아오기
        // let token = api.login(provider: "kakao", ...) 
        
        // 성공 시 토큰 저장 및 로그인 상태 변경
        let mockToken = "kakao_mock_auth_token_\(UUID().uuidString)"
        self.authToken = mockToken
        self.isLoggedIn = true
        print("카카오 로그인 성공: 토큰 저장됨")
    }
    
    // 애플 로그인 함수 (추후 실제 구현)
    private func performAppleLogin() {
        print("애플 로그인 시도")
        // 실제 로그인 구현 시 이 부분에 코드 추가
        // 로그인 API 호출하여 토큰 받아오기
        // let token = api.login(provider: "apple", ...) 
        
        // 성공 시 토큰 저장 및 로그인 상태 변경
        let mockToken = "apple_mock_auth_token_\(UUID().uuidString)"
        self.authToken = mockToken
        self.isLoggedIn = true
        print("애플 로그인 성공: 토큰 저장됨")
    }
}

#Preview {
    LoginView()
}

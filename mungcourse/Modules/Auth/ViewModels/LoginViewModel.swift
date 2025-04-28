import Foundation
import Combine
import SwiftUI

class LoginViewModel: ObservableObject {
    // 상태 관련 published 속성들
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // 인증 서비스
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // 앱 스토리지 (UserDefaults 래퍼) - 뷰에서 주입받음
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("authToken") private var authToken: String = ""
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    // 구글 로그인 메소드
    func loginWithGoogle() {
        // 로딩 상태 설정
        isLoading = true
        errorMessage = nil
        
        authService.loginWithGoogle()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                
                // 로딩 상태 해제
                self.isLoading = false
                
                switch result {
                case .success(let token):
                    print("구글 로그인 성공: \(token)")
                    // 인증 정보 저장
                    self.authToken = token
                    self.isLoggedIn = true
                case .failure(let error):
                    print("구글 로그인 실패: \(error.localizedDescription)")
                    // 에러 메시지 설정
                    self.errorMessage = error.localizedDescription
                }
            }
            .store(in: &cancellables)
    }
    
    // 애플 로그인 메소드
    func loginWithApple() {
        // 로딩 상태 설정
        isLoading = true
        errorMessage = nil
        
        authService.loginWithApple()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                
                // 로딩 상태 해제
                self.isLoading = false
                
                switch result {
                case .success(let token):
                    print("애플 로그인 성공: \(token)")
                    // 인증 정보 저장
                    self.authToken = token
                    self.isLoggedIn = true
                case .failure(let error):
                    print("애플 로그인 실패: \(error.localizedDescription)")
                    // 에러 메시지 설정
                    self.errorMessage = error.localizedDescription
                }
            }
            .store(in: &cancellables)
    }
    
    // 로그아웃 메소드
    func logout() {
        authService.logout()
        self.authToken = ""
        self.isLoggedIn = false
    }
}

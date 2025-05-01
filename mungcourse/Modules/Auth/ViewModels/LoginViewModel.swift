import Foundation
import Combine
import SwiftUI

// 에러 메시지를 Identifiable로 만들기 위한 구조체
struct IdentifiableError: Identifiable {
    let id = UUID()
    let message: String
}

class LoginViewModel: ObservableObject {
    // 상태 관련 published 속성들
    @Published var isLoading = false
    @Published var errorMessage: IdentifiableError? = nil
    
    // 인증 서비스
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // 앱 스토리지 (UserDefaults 래퍼) - 뷰에서 주입받음
    @AppStorage("isLoggedIn") private(set) var isLoggedIn: Bool = false
    // AppStorage for token; will set after dog registration or if dogs exist
    @AppStorage("authToken") private var authToken: String = ""
    // Temporarily hold auth token until dog registration
    private var pendingAuthToken: String? = nil
    @Published var needsDogRegistration: Bool = false
    
    private let dogService: DogServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared, dogService: DogServiceProtocol = DogService.shared) {
        self.authService = authService
        self.dogService = dogService
    }
    
    // 로그인 상태 확인 메소드
    func checkLoginStatus() {
        // 이미 로그인되어 있고 authToken이 있으면 바로 메인으로 이동
        if isLoggedIn && !authToken.isEmpty {
            print("이미 로그인 된 상태입니다: 토큰 - \(authToken)")
        } else {
            // 로그인이 필요한 상태
            isLoggedIn = false
            authToken = ""
        }
    }
    
    // 카카오 로그인 메소드
    func loginWithKakao() {
        // 로딩 상태 설정
        isLoading = true
        errorMessage = nil
        
        // 카카오 로그인 로직 구현 (임시로 애플 로그인을 호출)
        print("카카오 로그인 시도")
        authService.loginWithApple()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                
                // 로딩 상태 해제
                self.isLoading = false
                
                switch result {
                case .success(let token):
                    // 토큰을 임시 저장하고 등록된 반려견 조회
                    self.pendingAuthToken = token
                    self.checkDogs()
                case .failure(let error):
                    // 에러 메시지 설정
                    self.errorMessage = IdentifiableError(message: error.localizedDescription)
                }
            }
            .store(in: &cancellables)
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
                    // 토큰을 임시 저장하고 등록된 반려견 조회
                    self.pendingAuthToken = token
                    self.checkDogs()
                case .failure(let error):
                    // 에러 메시지 설정
                    self.errorMessage = IdentifiableError(message: error.localizedDescription)
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
                    // 토큰을 임시 저장하고 등록된 반려견 조회
                    self.pendingAuthToken = token
                    self.checkDogs()
                case .failure(let error):
                    // 에러 메시지 설정
                    self.errorMessage = IdentifiableError(message: error.localizedDescription)
                }
            }
            .store(in: &cancellables)
    }
    
    private func checkDogs() {
        isLoading = true
        dogService.fetchDogs()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = IdentifiableError(message: error.localizedDescription)
                }
            } receiveValue: { [weak self] dogs in
                guard let self = self else { return }
                if dogs.isEmpty {
                    // 반려견이 없으면 등록 화면으로
                    self.needsDogRegistration = true
                    print("반려견 등록 화면으로 이동")
                } else if let token = self.pendingAuthToken {
                    // 반려견이 이미 등록되어 있으면 로그인 완료 및 토큰 저장
                    self.authToken = token
                    self.isLoggedIn = true
                    print("반려견 있음: 로그인 완료, 메인 화면으로 이동")
                }
            }
            .store(in: &cancellables)
    }
    
    // 반려견 등록 메소드
    func registerDog(name: String, age: Int, breed: String) {
        isLoading = true
        errorMessage = nil
        dogService.registerDog(name: name, age: age, breed: breed)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = IdentifiableError(message: error.localizedDescription)
                }
            } receiveValue: { [weak self] dog in
                guard let self = self else { return }
                // 등록 성공 시 토큰 저장 및 로그인 완료
                if let token = self.pendingAuthToken {
                    self.authToken = token
                }
                self.needsDogRegistration = false
                self.isLoggedIn = true
                print("반려견 등록 완료: 메인 화면으로 이동")
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

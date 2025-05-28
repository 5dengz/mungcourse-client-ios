import Foundation
import Combine
import SwiftUI

// MARK: - 데이터 모델
// DogRegistrationData는 이제 RegisterDog/Models/DogRegistrationData.swift에서 import하여 사용합니다.

// MARK: - LoginViewModel
class LoginViewModel: ObservableObject {
    // MARK: - 내부 모델
    struct Dog: Identifiable {
        let id: Int
        let name: String
        let dogImgUrl: String?
        let isMain: Bool
    }
    
    struct S3PresignedUrlResponse {
        let preSignedUrl: String
        let imageUrl: String
    }
    
    // MARK: - 상태 속성
    @Published var isLoading = false
    @Published var errorMessage: IdentifiableError? = nil
    @Published var needsDogRegistration: Bool = false  // 반려견 등록 화면 표시 여부
    // 로그인 상태는 TokenManager.shared.accessToken으로 관리합니다
    
    // MARK: - 서비스
    private let loginUseCase: LoginUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 초기화
    init(loginUseCase: LoginUseCaseProtocol = LoginUseCase()) {
        self.loginUseCase = loginUseCase
    }
    
    // MARK: - 로그인 관련 메서드
    func checkLoginStatus() {
        guard let token = TokenManager.shared.getAccessToken(), !token.isEmpty else {
            // 토큰 없음: 로그아웃 처리
            // authService.logout()
            print("로그인 정보 없음: 재로그인 필요")
            return
        }
        if !isTokenValid(token) {
            // 토큰 만료: 로그아웃 처리
            // authService.logout()
            print("토큰 만료: 재로그인 필요")
        }
    }
    
    private func isTokenValid(_ token: String) -> Bool {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else { return false }
        
        var base64 = String(segments[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 = base64.padding(toLength: base64.count + 4 - remainder, withPad: "=", startingAt: 0)
        }
        
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return false
        }
        return Date(timeIntervalSince1970: exp) > Date()
    }
    
    func loginWithKakao() {
        isLoading = true
        errorMessage = nil
        
        print("카카오 로그인 시도")
        loginUseCase.login(provider: .kakao)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished:
                    self.checkDogs()
                case .failure(let error):
                    self.errorMessage = IdentifiableError(message: error.localizedDescription)
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func loginWithGoogle() {
        isLoading = true
        errorMessage = nil
        
        loginUseCase.login(provider: .google)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished:
                    // 로그인 성공 시에만 강아지 체크
                    if let token = TokenManager.shared.getAccessToken(), !token.isEmpty {
                        print("[LoginViewModel] 구글 로그인 성공: 반려견 정보 확인")
                        self.checkDogs()
                    } else {
                        print("[LoginViewModel] 구글 로그인 완료되었으나 토큰이 없음")
                    }
                case .failure(let error):
                    print("[LoginViewModel] 구글 로그인 실패 또는 취소: \(error.localizedDescription)")
                    self.errorMessage = IdentifiableError(message: error.localizedDescription)
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func loginWithApple() {
        isLoading = true
        errorMessage = nil
        
        loginUseCase.login(provider: .apple)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished:
                    // 로그인 성공 시에만 강아지 체크
                    if let token = TokenManager.shared.getAccessToken(), !token.isEmpty {
                        print("[LoginViewModel] 애플 로그인 성공: 반려견 정보 확인")
                        self.checkDogs()
                    } else {
                        print("[LoginViewModel] 애플 로그인 완료되었으나 토큰이 없음")
                    }
                case .failure(let error):
                    print("[LoginViewModel] 애플 로그인 실패 또는 취소: \(error.localizedDescription)")
                    self.errorMessage = IdentifiableError(message: error.localizedDescription)
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    // MARK: - 반려견 관련 메서드
    private func checkDogs() {
        isLoading = true
        
        // 토큰 유효성 먼저 확인
        guard let token = TokenManager.shared.getAccessToken(), !token.isEmpty else {
            print("[LoginViewModel] 토큰 없음: 바로 로그인 화면으로 유지")
            isLoading = false
            return
        }
        
        if !TokenManager.shared.validateTokens() {
            print("[LoginViewModel] 토큰 유효하지 않음: 토큰 갱신 시도")
            TokenManager.shared.refreshAccessToken { [weak self] success in
                guard let self = self else { return }
                
                if !success {
                    print("[LoginViewModel] 토큰 갱신 실패: 바로 로그인 화면으로 유지")
                    self.isLoading = false
                    return
                }
                
                // 토큰 갱신 성공 시 반려견 정보 요청 계속 진행
                print("[LoginViewModel] 토큰 갱신 성공: 반려견 치크 진행")
                self.proceedWithDogCheck()
            }
        } else {
            // 토큰이 유효한 경우 바로 반려견 정보 요청
            print("[LoginViewModel] 토큰 유효함: 반려견 치크 진행")
            proceedWithDogCheck()
        }
    }
    
    // 반려견 정보 치크 진행 (토큰 유효성 확인 후 호출되는 메서드)
    private func proceedWithDogCheck() {
        print("[LoginViewModel] 반려견 정보 확인 시작")
        
        // DogService를 통해 실제 반려견 데이터 확인
        DogService.shared.fetchDogs()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    self.isLoading = false
                    
                    if case .failure(let error) = completion {
                        print("[LoginViewModel] 반려견 정보 확인 실패: \(error.localizedDescription)")
                        
                        // 네트워크 오류 등의 경우 토큰 유효성을 다시 확인
                        if TokenManager.shared.validateTokens() {
                            // 토큰은 유효하지만 API 호출 실패 시, 안전하게 등록 화면으로 이동
                            print("[LoginViewModel] API 오류로 인해 반려견 등록 화면으로 이동")
                            self.needsDogRegistration = true
                        } else {
                            print("[LoginViewModel] 토큰 무효화로 인한 데이터 리셋")
                            NotificationCenter.default.post(name: .appDataDidReset, object: nil)
                        }
                    }
                },
                receiveValue: { [weak self] dogs in
                    guard let self = self else { return }
                    
                    // 반려견이 존재하는지 확인
                    if dogs.isEmpty {
                        print("[LoginViewModel] 등록된 반려견이 없음: 반려견 등록 화면으로 이동")
                        self.needsDogRegistration = true
                    } else {
                        print("[LoginViewModel] 등록된 반려견 \(dogs.count)마리 확인: 메인 화면으로 이동")
                        self.needsDogRegistration = false
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func registerDog(name: String, age: Int, breed: String) {
        isLoading = true
        errorMessage = nil
        
        // 더미 구현 - 항상 성공
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            
            self.needsDogRegistration = false
            print("반려견 등록 완료: 메인 화면으로 이동")
        }
    }
    
    func registerDogWithImage(name: String, gender: String, breed: String, birthDate: String, weight: Double, neutered: Bool, hasArthritis: Bool, imageData: Data?) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // 1. 이미지 업로드 시뮬레이션
                var finalImageUrl: String? = nil
                if let _ = imageData {
                    // 실제 구현에서는 S3에 이미지 업로드
                    // 올바른 Task.sleep 사용법
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1초 지연
                    
                    // 에러 가능성 추가 (네트워크 요청 실패 시뮬레이션)
                    if Bool.random() && false { // false로 설정하여 실제론 항상 성공하도록 함
                        throw NSError(domain: "ImageUploadError", code: 500, userInfo: [NSLocalizedDescriptionKey: "이미지 업로드 실패"])
                    }
                    
                    finalImageUrl = "https://example.com/images/dummy.jpg"
                }
                
                // 2. 반려견 정보 등록 시뮬레이션
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                let postedAtString = isoFormatter.string(from: Date())
                
                let dogData = DogRegistrationData(
                    name: name,
                    gender: gender,
                    breed: breed,
                    birthDate: birthDate,
                    weight: weight,
                    postedAt: postedAtString,
                    hasArthritis: hasArthritis,
                    neutered: neutered,
                    dogImgUrl: finalImageUrl
                )
                
                // 실제 구현에서는 API 호출
                // 올바른 Task.sleep 사용법
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1초 지연
                
                // 에러 가능성 추가 (API 요청 실패 시뮬레이션)
                if Bool.random() && false { // false로 설정하여 실제론 항상 성공하도록 함
                    throw NSError(domain: "APIError", code: 400, userInfo: [NSLocalizedDescriptionKey: "API 요청 실패"])
                }
                
                print("반려견 등록 성공: \(dogData.name)")
                
                // 3. 토큰 유효성 확인
                if let token = TokenManager.shared.getAccessToken(), !token.isEmpty {
                    print("[LoginViewModel] 반려견 등록 완료: 토큰 유효함 - \(token.prefix(10))...")
                } else {
                    print("[LoginViewModel] 반려견 등록 완료: 토큰 상태 이상")
                }
                
                // 4. 로그인 완료
                await MainActor.run {
                    self.needsDogRegistration = false
                    self.isLoading = false
                    print("[LoginViewModel] Registration complete.")
                }
            } catch {
                print("반려견 등록 중 오류 발생: \(error.localizedDescription)")
                await MainActor.run {
                    self.errorMessage = IdentifiableError(message: "반려견 등록 중 오류가 발생했습니다: \(error.localizedDescription)")
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - 로그아웃 메서드
    func logout() {
        // authService.logout()
    }
}

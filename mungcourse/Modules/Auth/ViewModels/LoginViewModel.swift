import Foundation
import Combine
import SwiftUI

// MARK: - 데이터 모델
struct DogRegistrationData: Encodable {
    let name: String
    let gender: String
    let breed: String
    let birthDate: String // "yyyy-MM-dd"
    let weight: Double
    let postedAt: String // ISO8601 format
    let hasArthritis: Bool
    let neutered: Bool
    var dogImgUrl: String?
}

// MARK: - 에러 타입
struct IdentifiableError: Identifiable {
    let id = UUID()
    let message: String
}

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
    @AppStorage("isLoggedIn") private(set) var isLoggedIn: Bool = false
    @AppStorage("authToken") private var authToken: String = ""
    private var pendingAuthToken: String? = nil
    @Published var needsDogRegistration: Bool = false
    
    // MARK: - 서비스
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 초기화
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    // MARK: - 로그인 관련 메서드
    func checkLoginStatus() {
        guard let token = TokenManager.shared.getAccessToken(), !token.isEmpty else {
            isLoggedIn = false
            authToken = ""
            print("로그인 정보 없음: 재로그인 필요")
            return
        }
        
        if isTokenValid(token) {
            authToken = token
            isLoggedIn = true
            print("로그인 유지: 유효한 토큰")
        } else {
            logout()
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
        authService.loginWithApple() // 임시 구현
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let token):
                    self.pendingAuthToken = token
                    self.checkDogs()
                case .failure(let error):
                    self.errorMessage = IdentifiableError(message: error.localizedDescription)
                }
            }
            .store(in: &cancellables)
    }
    
    func loginWithGoogle() {
        isLoading = true
        errorMessage = nil
        
        authService.loginWithGoogle()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let token):
                    self.pendingAuthToken = token
                    self.checkDogs()
                case .failure(let error):
                    self.errorMessage = IdentifiableError(message: error.localizedDescription)
                }
            }
            .store(in: &cancellables)
    }
    
    func loginWithApple() {
        isLoading = true
        errorMessage = nil
        
        authService.loginWithApple()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let token):
                    self.pendingAuthToken = token
                    self.checkDogs()
                case .failure(let error):
                    self.errorMessage = IdentifiableError(message: error.localizedDescription)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 반려견 관련 메서드
    private func checkDogs() {
        isLoading = true
        
        // 더미 구현 - 항상 빈 배열 반환
        // 실제 구현에서는 API 호출을 통해 반려견 데이터를 가져옴
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            
            // 더미 구현: 반려견이 없다고 가정
            self.needsDogRegistration = true
            print("반려견 등록 화면으로 이동")
        }
    }
    
    func registerDog(name: String, age: Int, breed: String) {
        isLoading = true
        errorMessage = nil
        
        // 더미 구현 - 항상 성공
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            
            if let token = self.pendingAuthToken {
                self.authToken = token
            }
            self.needsDogRegistration = false
            self.isLoggedIn = true
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
                
                // 3. 로그인 완료
                await MainActor.run {
                    if let token = self.pendingAuthToken {
                        self.authToken = token
                        print("Auth token saved.")
                    }
                    self.needsDogRegistration = false
                    self.isLoggedIn = true
                    self.isLoading = false
                    print("Registration complete. Logged in.")
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
        authService.logout()
        self.authToken = ""
        self.isLoggedIn = false
    }
}

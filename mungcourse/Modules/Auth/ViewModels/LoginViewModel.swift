import Foundation
import Combine
import SwiftUI

// Dog Registration Data Structure (matches API request body)
struct DogRegistrationData: Encodable {
    let name: String
    let gender: String
    let breed: String
    let birthDate: String // "yyyy-MM-dd"
    let weight: Double
    let postedAt: String // ISO8601 format
    let hasArthritis: Bool // Mapped from hasPatellarLuxationSurgery
    let neutered: Bool
    var dogImgUrl: String? // Optional image URL
}

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
        // Keychain에서 accessToken 조회
        guard let token = TokenManager.shared.getAccessToken(), !token.isEmpty else {
            // 로그인 정보 없으면 로그아웃 상태
            isLoggedIn = false
            authToken = ""
            print("로그인 정보 없음: 재로그인 필요")
            return
        }
        // 토큰 만료 여부 검사
        if isTokenValid(token) {
            // 유효한 토큰이면 로그인 상태 유지
            authToken = token
            isLoggedIn = true
            print("로그인 유지: 유효한 토큰 - \(token)")
        } else {
            // 만료된 토큰은 로그아웃 처리
            logout()
            print("토큰 만료: 재로그인 필요")
        }
    }
    
    // 토큰 만료(exp) 클레임을 확인하는 헬퍼 메소드
    private func isTokenValid(_ token: String) -> Bool {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else { return false }
        // Base64 페이로드 디코딩 준비
        var base64 = String(segments[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 = base64.padding(toLength: base64.count + 4 - remainder, withPad: "=", startingAt: 0)
        }
        // 디코딩 후 JSON 파싱
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return false
        }
        return Date(timeIntervalSince1970: exp) > Date()
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
    
    // 새로운 반려견 등록 메소드 (이미지 포함)
    func registerDogWithImage(name: String, gender: String, breed: String, birthDate: String, weight: Double, neutered: Bool, hasArthritis: Bool, imageData: Data?) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                var finalImageUrl: String? = nil
                
                // 1. Upload Image if provided
                if let data = imageData {
                    // Generate a unique filename (e.g., using UUID)
                    let fileName = UUID().uuidString
                    // Determine file extension (e.g., ".jpg") - requires more robust handling
                    let fileExtension = ".jpg"
                    
                    print("Requesting S3 pre-signed URL for \(fileName)(\(fileExtension)")
                    // Call service to get pre-signed URL
                    let s3Info = try await dogService.getS3PresignedUrl(fileName: fileName, fileExtension: fileExtension)
                    print("Received pre-signed URL: \(s3Info.preSignedUrl)")
                    
                    print("Uploading image to S3...")
                    // Call service to upload image data
                    try await dogService.uploadImageToS3(presignedUrl: s3Info.preSignedUrl, imageData: data)
                    print("Image uploaded successfully. Final URL: \(s3Info.imageUrl)")
                    finalImageUrl = s3Info.imageUrl
                }
                
                // 2. Register Dog Information
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Match "2025-05-02T02:47:50.015Z"
                let postedAtString = isoFormatter.string(from: Date())
                
                let dogData = DogRegistrationData(
                    name: name,
                    gender: gender,
                    breed: breed,
                    birthDate: birthDate, // Already formatted in View
                    weight: weight,
                    postedAt: postedAtString,
                    hasArthritis: hasArthritis,
                    neutered: neutered,
                    dogImgUrl: finalImageUrl
                )
                
                print("Registering dog information...")
                let registeredDog = try await dogService.registerDogWithDetails(dogData: dogData)
                print("Dog registered successfully: \(registeredDog)")
                
                // 3. Finalize Login
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
                // Handle errors from any step
                print("Error during dog registration: \(error)")
                await MainActor.run {
                    self.errorMessage = IdentifiableError(message: "반려견 등록 중 오류가 발생했습니다: \(error.localizedDescription)")
                    self.isLoading = false
                }
            }
        }
    }
    
    // 로그아웃 메소드
    func logout() {
        authService.logout()
        self.authToken = ""
        self.isLoggedIn = false
    }
}

import Foundation
import Combine
import GoogleSignIn
import KeychainAccess
import AuthenticationServices  // Apple Sign-In을 위해 AuthenticationServices 추가
import UIKit  // UIApplication 사용을 위해 추가
import CryptoKit  // SHA256 해싱을 위해 추가

// 인증 서비스 결과 타입
enum AuthResult {
    case success(token: String)
    case failure(error: Error)
}

// 인증 관련 에러 정의
enum AuthError: Error {
    case networkError
    case invalidCredentials
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .networkError:
            return "네트워크 연결에 문제가 있습니다."
        case .invalidCredentials:
            return "로그인 정보가 올바르지 않습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}

// 인증 서비스 프로토콜 - 테스트를 위한 모킹이 쉬워짐
protocol AuthServiceProtocol {
    func loginWithGoogle() -> AnyPublisher<AuthResult, Never>
    func loginWithApple() -> AnyPublisher<AuthResult, Never>
    func logout()
}

// 실제 인증 서비스 구현
class AuthService: AuthServiceProtocol {
    // Singleton 패턴 (앱 전체에서 하나의 인스턴스만 사용)
    static let shared = AuthService()
    private let keychain = Keychain(service: "com.mungcourse.app")
    private var appleSignInDelegate: AppleSignInDelegate?  // Apple 로그인 대리자 보관
    private var currentNonce: String?  // Apple Sign-In을 위한 nonce 저장
    
    private init() {}
    
    private static var apiBaseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? ""
    }
    
    /// 난수 nonce 문자열 생성
    private func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        while remainingLength > 0 {
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
        return result
    }
    
    /// SHA256 해싱
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }
    
    // 구글 로그인 메소드
    func loginWithGoogle() -> AnyPublisher<AuthResult, Never> {
        return Future<AuthResult, Never> { promise in
            DispatchQueue.main.async {
                guard let rootViewController = UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .first?.windows.first?.rootViewController else {
                    promise(.success(.failure(error: AuthError.unknown)))
                    return
                }
                GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                    if let error = error {
                        promise(.success(.failure(error: error)))
                        return
                    }
                    guard let idToken = result?.user.idToken?.tokenString else {
                        promise(.success(.failure(error: AuthError.unknown)))
                        return
                    }
                    print("[GoogleSignIn] id_token: \(idToken)") // 콘솔에 id_token 출력
                    // 서버로 idToken 전달
                    self.sendGoogleTokenToServer(idToken: idToken) { serverResult in
                        promise(.success(serverResult))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    // 서버로 idToken 전달 (POST /v1/auth/google/login)
    private func sendGoogleTokenToServer(idToken: String, completion: @escaping (AuthResult) -> Void) {
        guard let url = URL(string: "\(Self.apiBaseURL)/v1/auth/google/login") else {
            DispatchQueue.main.async {
                completion(.failure(error: AuthError.unknown))
            }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["idToken": idToken] // 서버 요구에 맞게 key를 idToken으로 변경
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("서버 통신 에러:", error)
                DispatchQueue.main.async {
                    completion(.failure(error: error))
                }
                return
            }
            if let response = response as? HTTPURLResponse {
                print("서버 응답 코드:", response.statusCode)
            }
            if let data = data, let body = String(data: data, encoding: .utf8) {
                print("서버 응답 body:", body)
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let dataDict = json["data"] as? [String: Any],
                  let tokens = dataDict["tokens"] as? [String: Any],
                  let accessToken = tokens["accessToken"] as? String,
                  let refreshToken = tokens["refreshToken"] as? String else {
                DispatchQueue.main.async {
                    completion(.failure(error: AuthError.unknown))
                }
                return
            }
            
            // 메인 스레드에서 토큰 저장 및 콜백 호출
            DispatchQueue.main.async {
                TokenManager.shared.saveTokens(accessToken: accessToken, refreshToken: refreshToken)
                completion(.success(token: accessToken))
            }
        }.resume()
    }
    
    // 애플 로그인 메소드
    func loginWithApple() -> AnyPublisher<AuthResult, Never> {
        return Future<AuthResult, Never> { [weak self] promise in
            guard let self = self else { return }
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            let nonce = self.randomNonceString()
            self.currentNonce = nonce
            request.requestedScopes = [.fullName, .email]
            request.nonce = self.sha256(nonce)
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            // 대리자 생성
            let delegate = AppleSignInDelegate(nonce: nonce) { result in
                switch result {
                case .success(let identityToken):
                    // 서버로 토큰 전송
                    self.sendAppleTokenToServer(identityToken: identityToken) { serverResult in
                        promise(.success(serverResult))
                    }
                case .failure(let error):
                    promise(.success(.failure(error: error)))
                }
            }
            authorizationController.delegate = delegate
            authorizationController.presentationContextProvider = delegate
            self.appleSignInDelegate = delegate
            DispatchQueue.main.async {
                authorizationController.performRequests()
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 서버로 identityToken 전달 (POST /v1/auth/apple/login)
    private func sendAppleTokenToServer(identityToken: String, completion: @escaping (AuthResult) -> Void) {
        guard let url = URL(string: "\(Self.apiBaseURL)/v1/auth/apple/login") else {
            DispatchQueue.main.async {
                completion(.failure(error: AuthError.unknown))
            }
            return
        }
        // nonce를 요청 본문에 함께 포함하기 위해 currentNonce 확인
        guard let nonce = self.currentNonce else {
            print("[AuthService] currentNonce가 nil입니다. Apple 로그인 요청에 nonce를 포함할 수 없습니다.")
            DispatchQueue.main.async {
                completion(.failure(error: AuthError.unknown))
            }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = [
            "identityToken": identityToken,
            "nonce": nonce
        ]
        // 요청 전체 로그 출력
        print("[AuthService] ● Apple 로그인 요청 ●")
        print("Method: \(request.httpMethod ?? "")")
        print("URL: \(url.absoluteString)")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        if let jsonData = try? JSONSerialization.data(withJSONObject: body),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Request Body: \(jsonString)")
            request.httpBody = jsonData
        } else {
            print("[AuthService] Apple 로그인 요청 본문 생성 실패")
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            // 응답 전체 로그 출력
            print("[AuthService] ● Apple 로그인 응답 ●")
            if let error = error {
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error: error))
                }
                return
            }
            guard let http = response as? HTTPURLResponse else {
                print("[AuthService] Apple 로그인 응답이 HTTPURLResponse가 아님")
                DispatchQueue.main.async {
                    completion(.failure(error: AuthError.unknown))
                }
                return
            }
            print("Status Code: \(http.statusCode)")
            print("Response Headers: \(http.allHeaderFields)")
            if let data = data, let bodyStr = String(data: data, encoding: .utf8) {
                print("Response Body: \(bodyStr)")
            } else {
                print("[AuthService] Apple 로그인 응답 바디 없음")
            }
            // 상태 코드별 에러 처리
            switch http.statusCode {
            case 200...299:
                break  // 정상 처리
            case 401, 403:
                print("[AuthService] Apple 로그인 정보 없음 (HTTP \(http.statusCode)): 토큰 초기화 및 재로그인 필요")
                DispatchQueue.main.async {
                    TokenManager.shared.clearTokens()
                    completion(.failure(error: AuthError.invalidCredentials))
                }
                return
            default:
                DispatchQueue.main.async {
                    completion(.failure(error: AuthError.unknown))
                }
                return
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let dataDict = json["data"] as? [String: Any],
                  let tokens = dataDict["tokens"] as? [String: Any],
                  let accessToken = tokens["accessToken"] as? String,
                  let refreshToken = tokens["refreshToken"] as? String else {
                DispatchQueue.main.async {
                    completion(.failure(error: AuthError.unknown))
                }
                return
            }
            // 메인 스레드에서 토큰 저장 및 콜백 호출
            DispatchQueue.main.async {
                TokenManager.shared.saveTokens(accessToken: accessToken, refreshToken: refreshToken)
                completion(.success(token: accessToken))
            }
        }.resume()
    }
    
    // 회원 탈퇴 메서드
    func deleteAccount() -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            guard let url = URL(string: "\(Self.apiBaseURL)/v1/auth/me") else {
                promise(.failure(AuthError.unknown))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            
            if let accessToken = TokenManager.shared.getAccessToken() {
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
            print("[AuthService] 회원 탈퇴 요청")
            print("URL: \(url.absoluteString)")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("[AuthService] 회원 탈퇴 통신 에러:", error)
                    DispatchQueue.main.async {
                        promise(.failure(error))
                    }
                    return
                }
                
                guard let http = response as? HTTPURLResponse else {
                    print("[AuthService] 회원 탈퇴 응답이 HTTPURLResponse가 아님")
                    DispatchQueue.main.async {
                        promise(.failure(AuthError.unknown))
                    }
                    return
                }
                
                print("[AuthService] 회원 탈퇴 응답 코드:", http.statusCode)
                
                if let data = data, let bodyStr = String(data: data, encoding: .utf8) {
                    print("[AuthService] 회원 탈퇴 응답 바디:", bodyStr)
                }
                
                switch http.statusCode {
                case 200...299:
                    // 성공 시 토큰 삭제 및 전체 데이터 초기화
                    DispatchQueue.main.async {
                        self.performFullAppDataReset()
                        TokenManager.shared.clearTokens()
                        promise(.success(true))
                    }
                case 401, 403:
                    print("[AuthService] 회원 탈퇴 권한 없음 (HTTP \(http.statusCode))")
                    DispatchQueue.main.async {
                        promise(.failure(AuthError.invalidCredentials))
                    }
                default:
                    DispatchQueue.main.async {
                        promise(.failure(AuthError.unknown))
                    }
                }
            }.resume()
        }.eraseToAnyPublisher()
    }
    
    /// 앱 전체 데이터 초기화 (UserDefaults, Keychain, URLCache, 싱글턴 등)
    private func performFullAppDataReset() {
        // UserDefaults 전체 삭제 (온보딩 데이터 유지)
        if let bundleID = Bundle.main.bundleIdentifier {
            let hasOnboarded = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.set(hasOnboarded, forKey: "hasCompletedOnboarding")
        }
        // Keychain 전체 삭제
        do {
            let keychain = Keychain(service: "com.mungcourse.app")
            try keychain.removeAll()
        } catch {
            print("[AuthService] Keychain 전체 삭제 실패: \(error)")
        }
        // URLCache 전체 삭제
        URLCache.shared.removeAllCachedResponses()
        // 쿠키 전체 삭제
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // 싱글턴/뷰모델 등 메모리 정보 초기화 (App에서 인스턴스 전달 필요)
        NotificationCenter.default.post(name: .appDataDidReset, object: nil)
    }
    
    // 로그아웃 메소드
    func logout() {
        print("로그아웃 처리")
        performFullAppDataReset()
        guard let url = URL(string: "\(Self.apiBaseURL)/v1/auth/logout") else {
            TokenManager.shared.clearTokens()
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let accessToken = TokenManager.shared.getAccessToken() {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("로그아웃 통신 에러:", error)
            } else if let http = response as? HTTPURLResponse {
                print("로그아웃 응답 코드:", http.statusCode)
            }
            TokenManager.shared.clearTokens()
        }.resume()
    }
}

// Apple Sign-In Delegate 클래스
private class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    typealias Completion = (Result<String, Error>) -> Void
    private let nonce: String?
    private let completion: Completion

    init(nonce: String?, completion: @escaping Completion) {
        self.nonce = nonce
        self.completion = completion
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // nonce 값이 있는지 확인하지만 실제로 사용하지 않음
        // 향후 JWT 토큰 검증에 사용할 예정
        guard let _ = nonce else {
            completion(.failure(AuthError.unknown))
            return
        }
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let tokenString = String(data: tokenData, encoding: .utf8) else {
            completion(.failure(AuthError.unknown))
            return
        }
        // TODO: 검증 필요 시 identityToken의 nonce 클레임이 currentNonce와 일치하는지 확인
        completion(.success(tokenString))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion(.failure(error))
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 현재 활성화된 윈도우 반환
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        if let window = scenes.first?.windows.first {
            return window
        }
        return ASPresentationAnchor()
    }
}

import Foundation
import Combine
import GoogleSignIn
import KeychainAccess
import AuthenticationServices  // Apple Sign-In을 위해 AuthenticationServices 추가
import UIKit  // UIApplication 사용을 위해 추가

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
    
    private init() {}
    
    private static var apiBaseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? ""
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
            completion(.failure(error: AuthError.unknown))
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
                completion(.failure(error: error))
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
                completion(.failure(error: AuthError.unknown))
                return
            }
            TokenManager.shared.saveTokens(accessToken: accessToken, refreshToken: refreshToken)
            completion(.success(token: accessToken))
        }.resume()
    }
    
    // 애플 로그인 메소드
    func loginWithApple() -> AnyPublisher<AuthResult, Never> {
        return Future<AuthResult, Never> { [weak self] promise in
            guard let self = self else { return }
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            // 필요한 경우 사용자 정보 요청
            // request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            // 대리자 생성
            let delegate = AppleSignInDelegate { result in
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
            completion(.failure(error: AuthError.unknown))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["identityToken": identityToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("애플 로그인 통신 에러:", error)
                completion(.failure(error: error))
                return
            }
            if let http = response as? HTTPURLResponse {
                print("애플 로그인 응답 코드:", http.statusCode)
            }
            if let data = data, let bodyStr = String(data: data, encoding: .utf8) {
                print("애플 로그인 응답 body:", bodyStr)
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let dataDict = json["data"] as? [String: Any],
                  let tokens = dataDict["tokens"] as? [String: Any],
                  let accessToken = tokens["accessToken"] as? String,
                  let refreshToken = tokens["refreshToken"] as? String else {
                completion(.failure(error: AuthError.unknown))
                return
            }
            // 토큰 저장
            TokenManager.shared.saveTokens(accessToken: accessToken, refreshToken: refreshToken)
            completion(.success(token: accessToken))
        }.resume()
    }
    
    // 로그아웃 메소드
    func logout() {
        print("로그아웃 처리")
        TokenManager.shared.clearTokens()
        // 여기서 실제 로그아웃 로직 구현
        // - 토큰 삭제
        // - 서버에 로그아웃 알림 등
    }
}

// Apple Sign-In Delegate 클래스
private class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    typealias Completion = (Result<String, Error>) -> Void
    private let completion: Completion

    init(completion: @escaping Completion) {
        self.completion = completion
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let tokenString = String(data: tokenData, encoding: .utf8) else {
            completion(.failure(error: AuthError.unknown))
            return
        }
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

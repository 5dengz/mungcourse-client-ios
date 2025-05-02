import Foundation
import Combine
import GoogleSignIn
import KeychainAccess

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
        return Future<AuthResult, Never> { promise in
            print("애플 로그인 API 호출 시작")
            
            // 여기서 실제 애플 로그인 로직이 구현될 예정
            // 현재는 모의 구현으로 항상 성공하는 것으로 가정
            
            // API 호출 지연 시뮬레이션
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // 성공 시 토큰 반환
                let token = "apple_auth_token_\(UUID().uuidString)"
                promise(.success(.success(token: token)))
            }
        }
        .eraseToAnyPublisher()
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

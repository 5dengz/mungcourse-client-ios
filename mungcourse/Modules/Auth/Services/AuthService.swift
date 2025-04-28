import Foundation
import Combine

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
    
    private init() {}
    
    // 구글 로그인 메소드
    func loginWithGoogle() -> AnyPublisher<AuthResult, Never> {
        return Future<AuthResult, Never> { promise in
            print("구글 로그인 API 호출 시작")
            // 실제 구글 로그인 로직을 여기에 구현해야 함 (현재는 모의 구현)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let token = "google_auth_token_\(UUID().uuidString)"
                promise(.success(.success(token: token)))
            }
        }
        .eraseToAnyPublisher()
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
        // 여기서 실제 로그아웃 로직 구현
        // - 토큰 삭제
        // - 서버에 로그아웃 알림 등
    }
}

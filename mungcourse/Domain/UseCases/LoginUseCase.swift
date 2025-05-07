import Foundation
import Combine
import Modules.Auth.ViewModels // if needed or import Data

public enum LoginProvider {
    case kakao, google, apple
}

public protocol LoginUseCaseProtocol {
    func login(provider: LoginProvider) -> AnyPublisher<Bool, Error>
    func logout()
}

public struct LoginUseCase: LoginUseCaseProtocol {
    private let authService: AuthServiceProtocol
    public init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }

    public func login(provider: LoginProvider) -> AnyPublisher<Bool, Error> {
        switch provider {
        case .kakao:
            return authService.loginWithKakao()
                .map { _ in true }
                .eraseToAnyPublisher()
        case .google:
            return authService.loginWithGoogle()
                .map { _ in true }
                .eraseToAnyPublisher()
        case .apple:
            return authService.loginWithApple()
                .map { _ in true }
                .eraseToAnyPublisher()
        }
    }

    public func logout() {
        authService.logout()
    }
}

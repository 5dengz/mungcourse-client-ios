import Foundation
import Combine

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    /// 공통 API 요청 함수
    func performAPIRequest(_ request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = request
        // accessToken이 있으면 Authorization 헤더에 추가
        if let accessToken = TokenManager.shared.getAccessToken() {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        // refreshToken이 있으면 Authorization-Refresh 헤더에 추가
        if let refreshToken = TokenManager.shared.getRefreshToken() {
            request.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization-Refresh")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                // accessToken 만료, refresh 시도
                TokenManager.shared.refreshAccessToken { success in
                    if success, let newToken = TokenManager.shared.getAccessToken() {
                        // 토큰 갱신 성공, 원래 요청을 accessToken 교체 후 재시도
                        var retriedRequest = request
                        retriedRequest.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
                        let retryTask = URLSession.shared.dataTask(with: retriedRequest) { data, response, error in
                            completion(data, response, error)
                        }
                        retryTask.resume()
                    } else {
                        // 갱신 실패, 로그아웃 처리
                        AuthService.shared.logout()
                        completion(nil, response, AuthError.invalidCredentials)
                    }
                }
            } else {
                completion(data, response, error)
            }
        }
        task.resume()
    }
    
    /// 토큰이 포함된 Combine Publisher 기반 API 요청 함수
    func requestWithTokenPublisher(_ request: URLRequest) -> AnyPublisher<(Data, URLResponse), Error> {
        var request = request
        
        // accessToken이 있으면 Authorization 헤더에 추가
        if let accessToken = TokenManager.shared.getAccessToken() {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            // 토큰이 없으면 오류 반환
            return Fail(error: URLError(.userAuthenticationRequired))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryCatch { [weak self] error -> AnyPublisher<(Data, URLResponse), Error> in
                guard let self = self else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                
                if let urlError = error as? URLError, urlError.code == .userAuthenticationRequired {
                    // 인증 실패 시 토큰 갱신 시도
                    return self.refreshTokenAndRetry(request)
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .tryCatch { [weak self] output -> AnyPublisher<(Data, URLResponse), Error> in
                guard let self = self, let response = output.response as? HTTPURLResponse else {
                    return Just(output).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                
                if response.statusCode == 401 {
                    // 401 응답 시 토큰 갱신 시도
                    return self.refreshTokenAndRetry(request)
                }
                return Just(output).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// 토큰 갱신 후 요청 재시도 함수
    private func refreshTokenAndRetry(_ request: URLRequest) -> AnyPublisher<(Data, URLResponse), Error> {
        return Future<String, Error> { promise in
            TokenManager.shared.refreshAccessToken { success in
                if success, let newToken = TokenManager.shared.getAccessToken() {
                    promise(.success(newToken))
                } else {
                    // 자동으로 로그아웃
                    AuthService.shared.logout()
                    promise(.failure(URLError(.userAuthenticationRequired)))
                }
            }
        }
        .flatMap { token -> AnyPublisher<(Data, URLResponse), Error> in
            var newRequest = request
            newRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return URLSession.shared.dataTaskPublisher(for: newRequest)
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

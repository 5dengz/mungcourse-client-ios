import Foundation
import Combine

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    /// 요청 전 토큰 검증 후 API 요청 실행 함수
    func performAPIRequest(_ request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        // API 요청 전 토큰 유효성 검사
        if !TokenManager.shared.validateTokens() {
            print("[NetworkManager] 토큰 만료 감지, 갱신 시도")
            // 토큰 갱신 시도
            TokenManager.shared.refreshAccessToken { success in
                if success {
                    print("[NetworkManager] 토큰 갱신 성공, 요청 진행")
                    // 갱신 성공 시 실제 요청 실행
                    self.performActualRequest(request, completion: completion)
                } else {
                    print("[NetworkManager] 토큰 갱신 실패, 로그인 필요 알림 발생")
                    // 갱신 실패 시 앱 데이터 리셋 알림 발생
                    DispatchQueue.main.async {
                        AuthService.shared.logout()
                        NotificationCenter.default.post(name: .appDataDidReset, object: nil)
                        completion(nil, nil, AuthError.invalidCredentials)
                    }
                }
            }
        } else {
            // 토큰 유효하면 바로 요청 진행
            performActualRequest(request, completion: completion)
        }
    }
    
    /// 실제 API 요청 실행 함수 (내부용)
    private func performActualRequest(_ request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = request
        // accessToken이 있으면 Authorization 헤더에 추가
        if let accessToken = TokenManager.shared.getAccessToken() {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            print("[NetworkManager] Authorization 헤더 추가: Bearer \(accessToken)")
        } else {
            print("[NetworkManager] accessToken 없음 - Authorization 헤더 미포함")
        }
        // refreshToken이 있으면 Authorization-Refresh 헤더에 추가
        if let refreshToken = TokenManager.shared.getRefreshToken() {
            request.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization-Refresh")
            print("[NetworkManager] Authorization-Refresh 헤더 추가: Bearer \(refreshToken)")
        } else {
            print("[NetworkManager] refreshToken 없음 - Authorization-Refresh 헤더 미포함")
        }
        print("[NetworkManager] 요청 URL: \(request.url?.absoluteString ?? "nil")")
        print("[NetworkManager] 요청 메서드: \(request.httpMethod ?? "nil")")
        print("[NetworkManager] 요청 헤더: \(request.allHTTPHeaderFields ?? [:])")
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("[NetworkManager] 요청 바디: \(bodyString)")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("[NetworkManager] 응답 상태 코드: \(httpResponse.statusCode)")
                print("[NetworkManager] 응답 헤더: \(httpResponse.allHeaderFields)")
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("[NetworkManager] 응답 데이터: \(responseString)")
            }
            if let error = error {
                print("[NetworkManager] 네트워크 에러: \(error.localizedDescription)")
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                // accessToken 만료, refresh 시도
                print("[NetworkManager] 401 에러 - 토큰 갱신 시도")
                TokenManager.shared.refreshAccessToken { success in
                    if success, let newToken = TokenManager.shared.getAccessToken() {
                        print("[NetworkManager] 토큰 갱신 성공, 재요청 진행")
                        // 토큰 갱신 성공, 원래 요청을 accessToken 교체 후 재시도
                        var retriedRequest = request
                        retriedRequest.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
                        let retryTask = URLSession.shared.dataTask(with: retriedRequest) { data, response, error in
                            if let httpResponse = response as? HTTPURLResponse {
                                print("[NetworkManager] (재요청) 응답 상태 코드: \(httpResponse.statusCode)")
                                print("[NetworkManager] (재요청) 응답 헤더: \(httpResponse.allHeaderFields)")
                            }
                            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                                print("[NetworkManager] (재요청) 응답 데이터: \(responseString)")
                            }
                            if let error = error {
                                print("[NetworkManager] (재요청) 네트워크 에러: \(error.localizedDescription)")
                            }
                            completion(data, response, error)
                        }
                        retryTask.resume()
                    } else {
                        print("[NetworkManager] 토큰 갱신 실패 - 로그아웃 처리")
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
    
    /// 토큰 검증 후 Combine Publisher 기반 API 요청 함수
    func requestWithTokenPublisher(_ request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
        // API 요청 전 토큰 유효성 검사
        if !TokenManager.shared.validateTokens() {
            // 토큰 갱신 시도 후 요청
            return Future<Void, Error> { promise in
                TokenManager.shared.refreshAccessToken { success in
                    if success {
                        promise(.success(()))
                    } else {
                        // 갱신 실패 시 앱 데이터 리셋 알림 발생
                        DispatchQueue.main.async {
                            AuthService.shared.logout()
                            NotificationCenter.default.post(name: .appDataDidReset, object: nil)
                        }
                        promise(.failure(AuthError.invalidCredentials))
                    }
                }
            }
            .flatMap { _ -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> in
                // 갱신 성공 시 실제 요청 진행
                return self.performActualRequestPublisher(request)
            }
            .eraseToAnyPublisher()
        } else {
            // 토큰 유효하면 바로 요청 진행
            return performActualRequestPublisher(request)
        }
    }
    
    /// 실제 Combine Publisher 기반 API 요청 실행 함수 (내부용)
    private func performActualRequestPublisher(_ request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
        var request = request
        
        // accessToken이 있으면 Authorization 헤더에 추가
        if let accessToken = TokenManager.shared.getAccessToken() {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            // 토큰이 없으면 오류 반환
            return Fail(error: URLError(.userAuthenticationRequired))
                .eraseToAnyPublisher()
        }
        // refreshToken이 있으면 Authorization-Refresh 헤더에 추가
        if let refreshToken = TokenManager.shared.getRefreshToken() {
            request.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization-Refresh")
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryCatch { [weak self] error -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> in
                guard let self = self else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                
                if error.code == .userAuthenticationRequired {
                    // 인증 실패 시 토큰 갱신 시도
                    return self.refreshTokenAndRetry(request)
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .flatMap { [weak self] output -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> in
                guard let self = self else {
                    // 명시적으로 URLSession.DataTaskPublisher.Output 타입의 값을 생성
                    return Just(output)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                guard let httpResponse = output.response as? HTTPURLResponse else {
                    // 명시적으로 URLSession.DataTaskPublisher.Output 타입의 값을 생성
                    return Just(output)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                if httpResponse.statusCode == 401 {
                    // 401 응답 시 토큰 갱신 시도
                    return self.refreshTokenAndRetry(request)
                }
                return Just(output)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// 토큰 갱신 후 요청 재시도 함수 (401 응답 후 호출됨)
    private func refreshTokenAndRetry(_ request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
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
        .flatMap { token -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> in
            var newRequest = request
            newRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            // refreshToken이 있으면 Authorization-Refresh 헤더에 추가
            if let refreshToken = TokenManager.shared.getRefreshToken() {
                newRequest.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization-Refresh")
            }
            return URLSession.shared.dataTaskPublisher(for: newRequest)
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

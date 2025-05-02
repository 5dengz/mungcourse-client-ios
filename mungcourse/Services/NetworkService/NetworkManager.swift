import Foundation

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
}

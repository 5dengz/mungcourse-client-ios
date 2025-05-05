import Foundation
import KeychainAccess
import Combine

final class TokenManager: ObservableObject {
    static let shared = TokenManager()
    private let keychain = Keychain(service: "com.mungcourse.app")
    @Published private(set) var accessToken: String?
    @Published private(set) var refreshToken: String?
    
    private init() {
        self.accessToken = keychain["accessToken"]
        self.refreshToken = keychain["refreshToken"]
    }
    
    // MARK: - 토큰 저장/조회/삭제
    func saveTokens(accessToken: String, refreshToken: String) {
        keychain["accessToken"] = accessToken
        keychain["refreshToken"] = refreshToken
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    func getAccessToken() -> String? {
        return accessToken
    }
    func getRefreshToken() -> String? {
        return refreshToken
    }
    func clearTokens() {
        keychain["accessToken"] = nil
        keychain["refreshToken"] = nil
        self.accessToken = nil
        self.refreshToken = nil
    }
    // MARK: - refreshToken으로 accessToken 갱신
    func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = getRefreshToken() else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        guard let url = URL(string: "https://api.mungcourse.online/v1/auth/refresh") else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["refreshToken": refreshToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("토큰 갱신 통신 에러:", error)
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            if let response = response as? HTTPURLResponse {
                print("토큰 갱신 응답 코드:", response.statusCode)
            }
            if let data = data, let body = String(data: data, encoding: .utf8) {
                print("토큰 갱신 응답 body:", body)
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let dataDict = json["data"] as? [String: Any],
                  let tokens = dataDict["tokens"] as? [String: Any],
                  let newAccessToken = tokens["accessToken"] as? String,
                  let newRefreshToken = tokens["refreshToken"] as? String else {
                DispatchQueue.main.async {
                    self.clearTokens()
                    completion(false)
                }
                return
            }
            DispatchQueue.main.async {
                self.saveTokens(accessToken: newAccessToken, refreshToken: newRefreshToken)
                completion(true)
            }
        }.resume()
    }
}

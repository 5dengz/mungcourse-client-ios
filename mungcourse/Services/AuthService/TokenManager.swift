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
        print("[TokenManager] 토큰 저장: \(accessToken.prefix(10))...")
        keychain["accessToken"] = accessToken
        keychain["refreshToken"] = refreshToken
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    func getAccessToken() -> String? {
        return accessToken
    }
    
    // 토큰 유효성 검증 메서드 추가
    func validateTokens() -> Bool {
        if let accessToken = self.accessToken, !accessToken.isEmpty {
            print("[TokenManager] 토큰 검증: 토큰 존재 (\(accessToken.prefix(10))...)")
            
            // 토큰 유효기간 확인
            let segments = accessToken.split(separator: ".")
            if segments.count == 3 {
                var base64 = String(segments[1])
                    .replacingOccurrences(of: "-", with: "+")
                    .replacingOccurrences(of: "_", with: "/")
                let remainder = base64.count % 4
                if remainder > 0 {
                    base64 = base64.padding(toLength: base64.count + 4 - remainder, withPad: "=", startingAt: 0)
                }
                
                if let data = Data(base64Encoded: base64),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let exp = json["exp"] as? TimeInterval {
                    let expiryDate = Date(timeIntervalSince1970: exp)
                    print("[TokenManager] 토큰 만료시간: \(expiryDate)")
                    let isValid = expiryDate > Date()
                    print("[TokenManager] 토큰 유효성: \(isValid ? "유효" : "만료")")
                    return isValid
                } else {
                    print("[TokenManager] 토큰 구문 분석 오류")
                }
            } else {
                print("[TokenManager] 토큰 형식 오류 (segments: \(segments.count))")
            }
            
            // 기본적으로 토큰이 존재하면 유효하다고 간주
            return true
        }
        print("[TokenManager] 토큰 검증: 토큰 없음")
        return false
    }
    func getRefreshToken() -> String? {
        return refreshToken
    }
    func clearTokens() {
        print("[TokenManager] 토큰 삭제")
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

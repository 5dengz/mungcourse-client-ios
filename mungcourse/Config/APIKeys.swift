import Foundation

/// Manages API keys for external services
enum APIKeys {
    // Naver Maps API keys
    static var naverClientId: String {
        // First try to get from environment
        if let envKey = ProcessInfo.processInfo.environment["NAVER_MAPS_CLIENT_ID"] {
            return envKey
        }
        
        // Then fallback to Info.plist
        guard let clientId = Bundle.main.infoDictionary?["NMFClientId"] as? String else {
            fatalError("Naver Maps Client ID not found. Add it to Info.plist as NMFClientId")
        }
        return clientId
    }
    
    static var naverClientSecret: String {
        // First try to get from environment
        if let envKey = ProcessInfo.processInfo.environment["NAVER_MAPS_CLIENT_SECRET"] {
            return envKey
        }
        
        // Then fallback to Info.plist
        guard let clientSecret = Bundle.main.infoDictionary?["NMFClientSecret"] as? String else {
            fatalError("Naver Maps Client Secret not found. Add it to Info.plist as NMFClientSecret")
        }
        return clientSecret
    }
}
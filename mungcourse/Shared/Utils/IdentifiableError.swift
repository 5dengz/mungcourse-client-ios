import Foundation

/// 에러 객체나 에러 메시지를 Identifiable로 래핑하는 구조체
/// SwiftUI의 alert(item:) 등에서 사용 가능
struct IdentifiableError: Identifiable {
    let id = UUID()
    let error: Error?
    let message: String
    
    /// 에러 객체로 초기화
    init(error: Error) {
        self.error = error
        self.message = error.localizedDescription
    }
    
    /// 에러 메시지로 초기화
    init(message: String) {
        self.error = nil
        self.message = message
    }
    
    /// 에러 객체와 사용자 정의 메시지로 초기화
    init(error: Error, message: String) {
        self.error = error
        self.message = message
    }
    
    /// 에러 메시지를 반환
    var localizedDescription: String {
        return message
    }
}
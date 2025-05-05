import Foundation
import NMapsMap

/// 산책 세션 데이터 - 산책 관련 모듈에서 공통으로 사용되는 데이터 모델
public struct WalkSessionData {
    let distance: Double // km
    let duration: Int // seconds
    let date: Date
    let coordinates: [NMGLatLng]
    
    public init(distance: Double, duration: Int, date: Date, coordinates: [NMGLatLng]) {
        self.distance = distance
        self.duration = duration
        self.date = date
        self.coordinates = coordinates
    }
} 
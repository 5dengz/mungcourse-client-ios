import Foundation

// API 응답 전체 구조
struct WalkResponse: Codable {
    let timestamp: String
    let statusCode: Int
    let message: String
    let data: Walk
    let success: Bool
}

// 산책 기록 데이터 모델
struct Walk: Codable, Identifiable {
    let id: Int
    let distanceKm: Double
    let durationSec: Int
    let calories: Int
    let startedAt: String
    let endedAt: String
    let routeRating: Int
    let dogIds: [Int]
    let gpsData: [GPSCoordinate]
    
    // 편의 기능들
    var formattedDistance: String {
        return String(format: "%.1f km", distanceKm)
    }
    
    var formattedDuration: String {
        let hours = durationSec / 3600
        let minutes = (durationSec % 3600) / 60
        let seconds = durationSec % 60
        
        if hours > 0 {
            return String(format: "%d시간 %d분", hours, minutes)
        } else {
            return String(format: "%d분 %d초", minutes, seconds)
        }
    }
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        guard let date = dateFormatter.date(from: startedAt) else {
            return "날짜 정보 없음"
        }
        
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH:mm"
        return dateFormatter.string(from: date)
    }
}

// GPS 좌표 데이터 모델
struct GPSCoordinate: Codable {
    let lat: Double
    let lng: Double
}
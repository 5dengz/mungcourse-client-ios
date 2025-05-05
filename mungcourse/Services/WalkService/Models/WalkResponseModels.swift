import Foundation

// 기본 API 응답 구조
struct BaseResponse<T: Codable>: Codable {
    let success: Bool
    let message: String
    let statusCode: Int
    let timestamp: String
    let data: T?
}

// 산책 API 응답 타입
typealias WalkDTOResponse = BaseResponse<WalkDTO>

// 산책 모델 (DTO)
struct WalkDTO: Codable, Identifiable {
    let id: Int
    let distanceKm: Double
    let durationSec: Int
    let calories: Int
    let startedAt: String
    let endedAt: String
    let routeRating: Double?
    let dogIds: [Int]
    let gpsData: [GpsPoint]
}

// GPS 포인트 모델
struct GpsPoint: Codable {
    let lat: Double
    let lng: Double
}

// MARK: - WalkHistory 관련 모델

// 월별 산책 날짜 응답 모델
typealias WalkDatesResponse = BaseResponse<[WalkDateResponse]>

// 산책 날짜 개별 응답 모델
struct WalkDateResponse: Codable, Identifiable {
    let id = UUID()
    let date: String // YYYY-MM-DD 형식
    
    enum CodingKeys: String, CodingKey {
        case date
    }
}

// 특정 날짜의 산책 기록 목록 응답 모델
typealias WalkRecordsResponse = BaseResponse<[WalkRecord]>

// 산책 기록 간단 정보 (목록용)
struct WalkRecord: Codable, Identifiable {
    let id: Int
    let distanceKm: Double
    let durationSec: Int
    let calories: Int
    let startedAt: String
    let endedAt: String
    let routeRating: Double?
    let dogIds: [Int]
    
    // 날짜 및 시간 표시용 계산 속성
    var formattedStartTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = dateFormatter.date(from: startedAt) {
            dateFormatter.dateFormat = "a h:mm"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            return dateFormatter.string(from: date)
        }
        return ""
    }
    
    // 소요 시간 표시 (분 단위)
    var formattedDuration: String {
        let minutes = durationSec / 60
        return "\(minutes)분"
    }
    
    // 소요 거리 (km 단위, 소수점 한자리)
    var formattedDistance: String {
        return String(format: "%.1f km", distanceKm)
    }
}

// 산책 기록 상세 응답 모델
typealias WalkDetailResponse = BaseResponse<WalkDetail>

// 산책 기록 상세 정보
struct WalkDetail: Codable, Identifiable {
    let id: Int
    let distanceKm: Double
    let durationSec: Int
    let calories: Int
    let startedAt: String
    let endedAt: String
    let routeRating: Double?
    let dogIds: [Int]
    let gpsData: [GpsPoint]
    
    // 날짜 및 시간 표시용 계산 속성
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = dateFormatter.date(from: startedAt) {
            dateFormatter.dateFormat = "yyyy년 M월 d일"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            return dateFormatter.string(from: date)
        }
        return ""
    }
    
    // 시작 시간
    var formattedStartTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = dateFormatter.date(from: startedAt) {
            dateFormatter.dateFormat = "a h:mm"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            return dateFormatter.string(from: date)
        }
        return ""
    }
    
    // 종료 시간
    var formattedEndTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = dateFormatter.date(from: endedAt) {
            dateFormatter.dateFormat = "a h:mm"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            return dateFormatter.string(from: date)
        }
        return ""
    }
    
    // 소요 시간 표시 (분 단위)
    var formattedDuration: String {
        let minutes = durationSec / 60
        return "\(minutes)분"
    }
    
    // 소요 거리 (km 단위, 소수점 한자리)
    var formattedDistance: String {
        return String(format: "%.1f km", distanceKm)
    }
} 
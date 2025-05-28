import Foundation
import CoreLocation
import NMapsMap

// 경로 종류 (일반/추천 등)
enum RouteType {
    case recommended
    case shortest
    case scenic
    case custom
    
    var title: String {
        switch self {
        case .recommended: return "추천 경로"
        case .shortest: return "최단 경로"
        case .scenic: return "경치 좋은 경로"
        case .custom: return "직접 설정"
        }
    }
    
    var description: String {
        switch self {
        case .recommended: return "애견 동반 특화 경로입니다"
        case .shortest: return "최단 거리로 돌아오는 경로입니다"
        case .scenic: return "자연경관이 좋은 경로입니다"
        case .custom: return "사용자가 직접 설정한 경로입니다"
        }
    }
}

// 경로 옵션 모델
struct RouteOption: Identifiable {
    let id = UUID()
    let type: RouteType
    let totalDistance: Double // 미터 단위
    let estimatedTime: Int // 분 단위
    let waypoints: [DogPlace]
    let coordinates: [NMGLatLng] // 네이버 맵 좌표 형식
    
    // 경로 정보 표시용 포맷
    var formattedDistance: String {
        if totalDistance < 1000 {
            return "\(Int(totalDistance))m"
        } else {
            return String(format: "%.1fkm", totalDistance / 1000)
        }
    }
    
    var formattedTime: String {
        if estimatedTime < 60 {
            return "\(estimatedTime)분"
        } else {
            let hours = estimatedTime / 60
            let minutes = estimatedTime % 60
            return "\(hours)시간 \(minutes)분"
        }
    }
} 
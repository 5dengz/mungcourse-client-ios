import Foundation

// MARK: - DogPlace 모델 (API 응답 데이터 구조)
struct DogPlace: Identifiable, Codable {
    let id: Int
    let name: String
    let dogPlaceImgUrl: String?
    let distance: Double
    let category: String
    let openingHours: String?
    let lat: Double
    let lng: Double
}

// MARK: - API 응답 전체 구조
enum DogPlaceCategory: String, Codable, CaseIterable {
    case all = ""
    case cafe, park, restaurant, hospital, etc
}

struct DogPlaceResponse: Codable {
    let timestamp: String
    let statusCode: Int
    let message: String
    let data: [DogPlace]
    let success: Bool
}

import Foundation

struct Dog: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let dogImgUrl: String?
    let isMain: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, dogImgUrl, isMain
    }
} 
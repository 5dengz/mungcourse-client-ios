import Foundation

struct Dog: Codable, Identifiable {
    let id: Int
    let name: String
    let age: Int
    let breed: String

    enum CodingKeys: String, CodingKey {
        case id, name, age, breed
    }
} 
// DogRegistrationData.swift
import Foundation

struct DogRegistrationData: Encodable {
    let name: String
    let gender: String
    let breed: String
    let birthDate: String // "yyyy-MM-dd"
    let weight: Double
    let postedAt: String // ISO8601 format
    let hasArthritis: Bool
    let neutered: Bool
    var dogImgUrl: String?
}

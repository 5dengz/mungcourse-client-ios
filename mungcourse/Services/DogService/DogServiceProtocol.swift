import Foundation
import Combine // 기존 Publisher 사용 함수가 있다면 유지

// S3 Pre-signed URL 응답 모델
struct S3PresignedUrlResponse: Decodable {
    let key: String
    let preSignedUrl: String
    let url: String

    private enum CodingKeys: String, CodingKey {
        case key
        case preSignedUrl
        case url
    }
}

// S3 Presigned URL 전체 응답 래퍼
struct S3PresignedUrlFullResponse: Decodable {
    let data: S3PresignedUrlResponse
}

// Dog 모델은 RegisterDog/Models/Dog.swift에서 import하여 사용합니다.

// API Response Wrappers
struct DogListResponse: Codable {
    let data: [Dog]
}

struct DogDataResponse: Codable {
    let data: Dog
}

// Service 전용 API 응답 래퍼
struct ServiceAPIResponse<T: Decodable>: Decodable {
    let statusCode: Int
    let message: String
    let data: T
    let timestamp: String
    let success: Bool
}

// 반려견 등록 전용 응답 모델 (서버가 id 없이 반환하는 필드에 맞춤)
struct DogRegistrationResponseData: Decodable {
    let id: Int?    // 반려견 ID 추가 (옵셔널로 변경)
    let name: String
    let gender: String
    let breed: String
    let birthDate: String
    let weight: Double
    let postedAt: String
    let hasArthritis: Bool
    let neutered: Bool
    let dogImgUrl: String?
    let isMain: Bool
}

// 강아지 산책 기록 모델
struct WalkRecordData: Decodable {
    let id: Int
    let distanceKm: Double
    let durationSec: Int
    let calories: Int
    let startedAt: String
    let endedAt: String
}

protocol DogServiceProtocol {
    // --- 기존 함수 시그니처 (Publisher 방식 예시) ---
    // 필요에 따라 async/await 방식으로 변경하거나 유지할 수 있습니다.
    func fetchDogs() -> AnyPublisher<[Dog], Error>
    func fetchMainDog() -> AnyPublisher<Dog, Error>
    func registerDog(name: String, age: Int, breed: String) -> AnyPublisher<Dog, Error> // 이 함수는 registerDogWithDetails로 대체될 수 있음

    // --- 새로 추가할 비동기 함수 시그니처 ---
    func getS3PresignedUrl(fileName: String, fileExtension: String) async throws -> S3PresignedUrlFullResponse
    func uploadImageToS3(presignedUrl: String, imageData: Data) async throws
    func registerDogWithDetails(dogData: DogRegistrationData) async throws -> DogRegistrationResponseData
    func fetchDogDetail(dogId: Int) async throws -> DogRegistrationResponseData
    // GET /v1/dogs/{dogId}/walks 강아지 산책 기록 조회
    func fetchWalkRecords(dogId: Int) async throws -> [WalkRecordData]
    // 강아지 정보 수정
    func updateDog(dogId: Int, dogData: DogRegistrationData) async throws -> DogRegistrationResponseData
    // 강아지 정보 삭제 추가
    func deleteDog(dogId: Int) async throws
    // 프로필 이미지(S3) 삭제 추가 (API: key)
    func deleteProfileImageS3(objectKey: String) async throws
}

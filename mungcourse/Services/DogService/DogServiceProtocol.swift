import Foundation
import Combine // 기존 Publisher 사용 함수가 있다면 유지

// S3 Pre-signed URL 응답 모델
struct S3PresignedUrlResponse: Decodable {
    let preSignedUrl: String // 서버 응답 키와 일치시켜야 합니다. 예: preSignedUrl, uploadUrl 등
    let imageUrl: String     // 서버 응답 키와 일치시켜야 합니다. 예: imageUrl, fileUrl 등
}

// Dog 모델은 RegisterDog/Models/Dog.swift에서 import하여 사용합니다.

// API Response Wrappers
struct DogListResponse: Codable {
    let data: [Dog]
}

struct DogDataResponse: Codable {
    let data: Dog
}


protocol DogServiceProtocol {
    // --- 기존 함수 시그니처 (Publisher 방식 예시) ---
    // 필요에 따라 async/await 방식으로 변경하거나 유지할 수 있습니다.
    func fetchDogs() -> AnyPublisher<[Dog], Error>
    func registerDog(name: String, age: Int, breed: String) -> AnyPublisher<Dog, Error> // 이 함수는 registerDogWithDetails로 대체될 수 있음

    // --- 새로 추가할 비동기 함수 시그니처 ---
    func getS3PresignedUrl(fileName: String, fileExtension: String) async throws -> S3PresignedUrlResponse
    func uploadImageToS3(presignedUrl: String, imageData: Data) async throws
    func registerDogWithDetails(dogData: DogRegistrationData) async throws -> Dog
}

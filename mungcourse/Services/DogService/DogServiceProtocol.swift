import Foundation
import Combine // 기존 Publisher 사용 함수가 있다면 유지

// S3 Pre-signed URL 응답 모델
struct S3PresignedUrlResponse: Decodable {
    let preSignedUrl: String // 서버 응답 키와 일치시켜야 합니다. 예: preSignedUrl, uploadUrl 등
    let imageUrl: String     // 서버 응답 키와 일치시켜야 합니다. 예: imageUrl, fileUrl 등
}

// Dog 모델 정의 (이미 존재하거나 다른 곳에 정의되어 있다면 해당 정의 사용)
struct Dog: Identifiable, Decodable {
    let id: Int // 또는 String, API 응답에 따라 조정
    let name: String
    let gender: String? // API 응답에 따라 옵셔널 여부 결정
    let breed: String?
    let birthDate: String? // "yyyy-MM-dd" 형식
    let weight: Double?
    let postedAt: String? // ISO8601 형식
    let hasArthritis: Bool?
    let neutered: Bool?
    let dogImgUrl: String?
    // 서버 응답에 따라 CodingKeys를 사용하여 매핑 필요할 수 있음
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
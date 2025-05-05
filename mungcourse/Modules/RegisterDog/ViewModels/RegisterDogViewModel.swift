import Foundation
import Combine
import SwiftUI
// DogRegistrationData는 같은 타겟 내에 있으므로 별도 import 없이 사용합니다.

// 반려견 등록에 필요한 Gender 열거형
enum Gender: String, CaseIterable, Identifiable {
    case female = "여아"
    case male = "남아"
    var id: String { self.rawValue }
}

// 에러 처리를 위한 구조체 (LoginViewModel에서 가져옴)
struct RegisterDogError: Identifiable {
    let id = UUID()
    let message: String
    
    // ErrorResponse에서 변환하는 생성자
    init(errorResponse: ErrorResponse) {
        self.message = errorResponse.message
    }
    
    // 문자열로 초기화하는 생성자
    init(message: String) {
        self.message = message
    }
}

class RegisterDogViewModel: ObservableObject {
    // MARK: - Published 속성
    @Published var name: String = ""
    @Published var gender: Gender? = nil
    @Published var breed: String = ""
    @Published var dateOfBirth: Date = Date()
    @Published var weight: String = ""
    @Published var isNeutered: Bool? = nil
    @Published var hasPatellarLuxationSurgery: Bool? = nil
    @Published var profileImage: Image? = nil
    @Published var selectedImageData: Data? = nil
    
    // UI 상태 관리
    @Published var isLoading: Bool = false
    @Published var errorMessage: RegisterDogError? = nil
    @Published var isRegistrationComplete: Bool = false
    
    // 서비스 의존성
    private let dogService: DogServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // API 기본 URL 설정
    private static var apiBaseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? ""
    }
    
    // MARK: - 초기화
    init(dogService: DogServiceProtocol = DogService.shared) {
        self.dogService = dogService
    }
    
    // MARK: - 계산 프로퍼티
    
    // 폼 유효성 검사
    var isFormValid: Bool {
        !name.isEmpty && 
        gender != nil && 
        !breed.isEmpty && 
        !weight.isEmpty && 
        Double(weight) != nil
    }
    
    // MARK: - 메서드
    
    // 반려견 등록 (이미지 포함)
    func registerDog() {
        guard isFormValid else {
            if name.isEmpty {
                errorMessage = RegisterDogError(message: "이름을 입력해주세요.")
            } else if gender == nil {
                errorMessage = RegisterDogError(message: "성별을 선택해주세요.")
            } else if breed.isEmpty {
                errorMessage = RegisterDogError(message: "견종을 선택해주세요.")
            } else if weight.isEmpty || Double(weight) == nil {
                errorMessage = RegisterDogError(message: "유효한 몸무게를 입력해주세요.")
            }
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // 날짜 형식 변환
        let birthDateFormatter = DateFormatter()
        birthDateFormatter.dateFormat = "yyyy-MM-dd"
        let birthDateString = birthDateFormatter.string(from: dateOfBirth)
        
        // 옵셔널 Bool 처리
        let neuteredStatus = isNeutered ?? false
        let arthritisStatus = hasPatellarLuxationSurgery ?? false
        
        // 몸무게 변환
        guard let weightDouble = Double(weight) else {
            isLoading = false
            errorMessage = RegisterDogError(message: "유효한 몸무게를 입력해주세요.")
            return
        }
        
        // 등록 데이터 준비
        let genderString = gender?.rawValue ?? ""
        
        Task {
            do {
                var finalImageUrl: String? = nil
                
                // 1. 이미지 업로드 (있는 경우)
                if let imageData = selectedImageData {
                    let fileName = UUID().uuidString
                    let fileExtension = ".jpg"

                    print("S3 Presigned URL 요청 중...")
                    let s3Info = try await dogService.getS3PresignedUrl(fileName: fileName, fileExtension: fileExtension)

                    print("이미지 업로드 중...")
                    try await dogService.uploadImageToS3(presignedUrl: s3Info.data.preSignedUrl, imageData: imageData)

                    finalImageUrl = s3Info.data.url
                    print("이미지 업로드 완료: \(finalImageUrl ?? "")")
                }
                
                // 2. 반려견 정보 등록
                let postedAtFormatter = DateFormatter()
                postedAtFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let postedAtString = postedAtFormatter.string(from: Date())
                
                let dogData = DogRegistrationData(
                    name: name,
                    gender: genderString,
                    breed: breed,
                    birthDate: birthDateString,
                    weight: weightDouble,
                    postedAt: postedAtString,
                    hasArthritis: arthritisStatus,
                    neutered: neuteredStatus,
                    dogImgUrl: finalImageUrl
                )
                
                print("반려견 정보 등록 중...")
                let registeredDog = try await dogService.registerDogWithDetails(dogData: dogData)
                print("반려견 등록 완료: \(registeredDog.name)")
                
                // 메인 스레드에서 UI 업데이트
                await MainActor.run {
                    isLoading = false
                    isRegistrationComplete = true
                }
                
            } catch {
                print("반려견 등록 오류: \(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                    errorMessage = RegisterDogError(message: "반려견 등록 중 오류가 발생했습니다: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // 반려견 수정 (이미지 포함)
    func updateDog(dogId: Int) {
        guard isFormValid else {
            if name.isEmpty {
                errorMessage = RegisterDogError(message: "이름을 입력해주세요.")
            } else if gender == nil {
                errorMessage = RegisterDogError(message: "성별을 선택해주세요.")
            } else if breed.isEmpty {
                errorMessage = RegisterDogError(message: "견종을 선택해주세요.")
            } else if weight.isEmpty || Double(weight) == nil {
                errorMessage = RegisterDogError(message: "유효한 몸무게를 입력해주세요.")
            }
            return
        }
        isLoading = true
        errorMessage = nil
        // 날짜 형식 변환
        let birthDateFormatter = DateFormatter()
        birthDateFormatter.dateFormat = "yyyy-MM-dd"
        let birthDateString = birthDateFormatter.string(from: dateOfBirth)
        // 옵셔널 Bool 처리
        let neuteredStatus = isNeutered ?? false
        let arthritisStatus = hasPatellarLuxationSurgery ?? false
        // 몸무게 변환
        guard let weightDouble = Double(weight) else {
            isLoading = false
            errorMessage = RegisterDogError(message: "유효한 몸무게를 입력해주세요.")
            return
        }
        // 등록 데이터 준비
        let genderString = gender?.rawValue ?? ""
        let postedAtFormatter = DateFormatter()
        postedAtFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let postedAtString = postedAtFormatter.string(from: Date())
        Task {
            do {
                var finalImageUrl: String? = nil
                // 이미지 업로드 (있는 경우)
                if let imageData = selectedImageData {
                    let fileName = UUID().uuidString
                    let fileExtension = ".jpg"
                    print("S3 Presigned URL 요청 중...")
                    let s3Info = try await dogService.getS3PresignedUrl(fileName: fileName, fileExtension: fileExtension)
                    print("이미지 업로드 중...")
                    try await dogService.uploadImageToS3(presignedUrl: s3Info.data.preSignedUrl, imageData: imageData)
                    finalImageUrl = s3Info.data.url
                    print("이미지 업로드 완료: \(finalImageUrl ?? "")")
                }
                let dogData = DogRegistrationData(
                    name: name,
                    gender: genderString,
                    breed: breed,
                    birthDate: birthDateString,
                    weight: weightDouble,
                    postedAt: postedAtString,
                    hasArthritis: arthritisStatus,
                    neutered: neuteredStatus,
                    dogImgUrl: finalImageUrl
                )
                print("반려견 정보 수정 중...")
                let updatedDog = try await dogService.updateDog(dogId: dogId, dogData: dogData)
                print("반려견 수정 완료: \(updatedDog.name)")
                await MainActor.run {
                    isLoading = false
                    isRegistrationComplete = true
                }
            } catch {
                print("반려견 수정 오류: \(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                    errorMessage = RegisterDogError(message: "반려견 수정 중 오류가 발생했습니다: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Delete Dog API
    func deleteDog(dogId: Int, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                print("➡️ ViewModel: Calling dogService.deleteDog(dogId: \(dogId))")
                try await dogService.deleteDog(dogId: dogId)
                print("✅ ViewModel: Dog deletion successful for ID \(dogId)")
                await MainActor.run {
                    isLoading = false
                    completion(true) // 성공 시 true 반환
                }
            } catch {
                print("❌ ViewModel: Error deleting dog ID \(dogId): \(error.localizedDescription)")
                // NetworkError를 구체적으로 처리하여 사용자에게 더 나은 메시지 제공 가능
                let message: String
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .missingToken:
                        message = "인증 토큰이 없습니다. 다시 로그인 해주세요."
                    case .httpError(let statusCode, _):
                        message = "삭제 중 오류가 발생했습니다 (코드: \(statusCode))."
                    default:
                        message = "삭제 중 오류가 발생했습니다: \(error.localizedDescription)"
                    }
                } else {
                    message = "알 수 없는 오류로 삭제에 실패했습니다: \(error.localizedDescription)"
                }
                
                await MainActor.run {
                    isLoading = false
                    errorMessage = RegisterDogError(message: message)
                    completion(false) // 실패 시 false 반환
                }
            }
        }
    }
    
    // 입력 필드 초기화
    func resetForm() {
        name = ""
        gender = nil
        breed = ""
        dateOfBirth = Date()
        weight = ""
        isNeutered = nil
        hasPatellarLuxationSurgery = nil
        profileImage = nil
        selectedImageData = nil
        errorMessage = nil
    }
    
    // MARK: - Mock API Implementation (for development)
    private func mockRegisterDogAPI() {
        // 테스트를 위한 지연 시간 추가
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            // 랜덤으로 성공/실패 처리 (테스트용)
            let isSuccess = true // Set to false to test error case
            
            if isSuccess {
                print("강아지 등록 성공 (목업)")
                self?.isRegistrationComplete = true
            } else {
                let errorResponse = ErrorResponse(
                    statusCode: 500,
                    message: "서버 오류가 발생했습니다. 다시 시도해주세요.",
                    error: "Server Error",
                    success: false,
                    timestamp: ""
                )
                self?.errorMessage = RegisterDogError(errorResponse: errorResponse)
            }
            
            self?.isLoading = false
        }
    }
}

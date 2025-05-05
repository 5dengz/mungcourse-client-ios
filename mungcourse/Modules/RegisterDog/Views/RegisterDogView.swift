import SwiftUI
// TODO: PhotosUI import for image picker functionality
import PhotosUI // Already added, but good practice to ensure
import UIKit
// TODO: Create a dedicated DogViewModel instead of using LoginViewModel

struct RegisterDogView: View {
    var initialDetail: DogRegistrationResponseData?  // 편집용 초기 데이터
    @StateObject private var viewModel: RegisterDogViewModel
    @EnvironmentObject var dogVM: DogViewModel // DogViewModel 추가
    @Environment(\.dismiss) private var dismiss
    // 완료 후 처리 클로저 (기본 nil)
    var onComplete: (() -> Void)? = nil
    // 뒤로가기 버튼 노출 여부
    var showBackButton: Bool = true
    // 삭제 확인 팝업 표시 상태
    @State private var showDeleteConfirmation = false
    // 마지막 강아지 삭제 시도 알림 표시 상태
    @State private var showLastDogAlert = false
    
    // 수정 모드 여부 계산
    private var isEditing: Bool {
        initialDetail != nil
    }
    
    // MARK: - Initializer
    init(initialDetail: DogRegistrationResponseData? = nil,
         onComplete: (() -> Void)? = nil,
         showBackButton: Bool = true) {
        self.initialDetail = initialDetail
        self.onComplete = onComplete
        self.showBackButton = showBackButton
        // ViewModel 생성 및 초기값 설정
        let vm = RegisterDogViewModel()
        if let detail = initialDetail {
            vm.name = detail.name
            vm.breed = detail.breed
            vm.gender = Gender(rawValue: detail.gender)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: detail.birthDate) {
                vm.dateOfBirth = date
            }
            vm.weight = String(detail.weight)
            vm.isNeutered = detail.neutered
            vm.hasPatellarLuxationSurgery = detail.hasArthritis
            if let urlString = detail.dogImgUrl,
               let url = URL(string: urlString) {
                // 동기 → 비동기 이미지 로딩
                Task {
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        if let uiImage = UIImage(data: data) {
                            await MainActor.run {
                                vm.profileImage = Image(uiImage: uiImage)
                                vm.selectedImageData = data
                            }
                        }
                    } catch {
                        print("[RegisterDogView] 이미지 비동기 로딩 실패: \(error)")
                    }
                }
            }
        }
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    // MARK: - Body
    var body: some View {
        // NavigationStack might still be needed for the navigation context, 
        // but header is now custom.
        NavigationStack { 
            ZStack { // ZStack 추가: 일반 화면과 모달을 겹쳐서 표시
                VStack(spacing: 0) { // Use spacing 0 if header shouldn't have gap below
                    CommonHeaderView(
                        leftIcon: showBackButton ? "arrow_back" : nil, // 조건부 노출
                        leftAction: showBackButton ? { dismiss() } : nil, // 조건부 노출
                        title: isEditing ? "반려견 정보 수정" : "반려견 정보 등록"
                    ) {
                        // 수정 모드일 때만 삭제 버튼 표시
                        if isEditing {
                            Button(action: { 
                                // 삭제 전 강아지 수 확인
                                if dogVM.dogs.count <= 1 {
                                    showLastDogAlert = true // 마지막 강아지 알림 표시
                                } else {
                                    showDeleteConfirmation = true // 삭제 확인 팝업 표시
                                }
                            }) {
                                Text("삭제")
                                    .font(.custom("Pretendard-Regular", size: 16))
                                    .foregroundColor(Color("gray300"))
                            }
                        }
                    }
                    
                    // ViewModel이 모든 상태를 관리하도록 변경
                    RegisterDogContentsView(
                        profileImage: $viewModel.profileImage,
                        selectedImageData: $viewModel.selectedImageData,
                        name: $viewModel.name,
                        gender: $viewModel.gender,
                        breed: $viewModel.breed,
                        dateOfBirth: $viewModel.dateOfBirth,
                        weight: $viewModel.weight,
                        isNeutered: $viewModel.isNeutered,
                        hasPatellarLuxationSurgery: $viewModel.hasPatellarLuxationSurgery,
                        errorMessage: viewModel.errorMessage?.message,
                        isFormValid: viewModel.isFormValid,
                        isLoading: viewModel.isLoading,
                        registerAction: registerAction,
                        isEditing: isEditing,
                        objectKey: (isEditing ? (initialDetail?.dogImgUrl.flatMap { url in
                            // S3 object key만 추출 (URL path에서 host 이후 부분)
                            if let u = URL(string: url) { return u.path.dropFirst() }
                            return nil
                        }) : nil).map(String.init),
                        viewModel: viewModel,
                        buttonTitle: (isEditing && viewModel.isModified) ? "수정하기" : "완료"
                    )
                    .padding(.horizontal, 20)
                    // Remove navigation modifiers from here
                    
                    Spacer() // Pushes content up if needed, depending on ScrollView behavior
                }
                .overlay { // Apply overlay to the VStack
                    if viewModel.isLoading {
                        Color.black.opacity(0.1).ignoresSafeArea()
                        ProgressView()
                    }
                }
                .navigationBarHidden(true) // Hide the default navigation bar
                .onChange(of: viewModel.isRegistrationComplete) { _, isComplete in
                    if isComplete {
                        // 등록 완료 시 처리: 우선 dismiss, 그 후 parent에게도 알림
                        dismiss()
                        onComplete?()
                    }
                }
                .alert("삭제 불가", isPresented: $showLastDogAlert) {
                    Button("확인") { }
                } message: {
                    Text("다른 반려견을 먼저 등록해주세요.")
                }

                // 삭제 확인 모달 추가
                if showDeleteConfirmation {
                    CommonPopupModal(
                        title: "반려견 정보 삭제",
                        message: "정보 삭제 시 반려견 정보 및 산책 기록은\n모두 삭제되어 복구가 불가능해요.\n\n정말로 삭제하시겠어요?",
                        cancelText: "취소",
                        confirmText: "삭제",
                        cancelAction: {
                            showDeleteConfirmation = false
                        },
                        confirmAction: {
                            deleteDog()
                            showDeleteConfirmation = false
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Computed Properties (Validation logic might stay here or move)
    private var isFormValid: Bool {
        !viewModel.name.isEmpty && viewModel.gender != nil && !viewModel.breed.isEmpty && !viewModel.weight.isEmpty
    }

    // MARK: - Actions (Registration logic stays in the main view)
    private func registerAction() {
        if isEditing, let detail = initialDetail, let id = detail.id {
            if viewModel.isModified {
                viewModel.updateDog(dogId: id)
            } else {
                dismiss()
            }
        } else {
            viewModel.registerDog()
        }
    }
    
    // 반려견 삭제 메서드
    private func deleteDog() {
        guard let dogDetail = initialDetail, let dogId = dogDetail.id else {
            // id가 없는 경우 에러 처리
            let errorResponse = ErrorResponse(
                statusCode: 400,
                message: "반려견 ID를 찾을 수 없습니다.",
                error: "Invalid ID",
                success: false,
                timestamp: ""
            )
            viewModel.errorMessage = RegisterDogError(errorResponse: errorResponse)
            return
        }
        
        viewModel.isLoading = true
        
        // API 호출을 통한 반려견 정보 삭제
        viewModel.deleteDog(dogId: dogId) { success in
            viewModel.isLoading = false
            
            if success {
                // 삭제 성공 시 DogViewModel 업데이트 후 화면 닫기
                DispatchQueue.main.async {
                    // DogViewModel의 dogs 배열을 업데이트하기 위해 fetchDogs 호출
                    self.dogVM.fetchDogs()
                    // 화면 닫기
                    self.dismiss()
                    // 완료 콜백 호출
                    self.onComplete?()
                }
            } else {
                // 삭제 실패 시 에러 메시지 표시
                let errorResponse = ErrorResponse(
                    statusCode: 500,
                    message: "반려견 정보 삭제 중 오류가 발생했습니다.",
                    error: "Unknown error",
                    success: false,
                    timestamp: ""
                )
                viewModel.errorMessage = RegisterDogError(errorResponse: errorResponse)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    RegisterDogView()
        .environmentObject(DogViewModel()) // Preview에 DogViewModel 추가
}

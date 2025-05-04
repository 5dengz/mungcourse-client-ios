import SwiftUI
// TODO: PhotosUI import for image picker functionality
import PhotosUI // Already added, but good practice to ensure
import UIKit
// TODO: Create a dedicated DogViewModel instead of using LoginViewModel

struct RegisterDogView: View {
    var initialDetail: DogRegistrationResponseData?  // 편집용 초기 데이터
    @StateObject private var viewModel: RegisterDogViewModel
    @Environment(\.dismiss) private var dismiss
    // 완료 후 처리 클로저 (기본 nil)
    var onComplete: (() -> Void)? = nil
    // 뒤로가기 버튼 노출 여부
    var showBackButton: Bool = true
    // 삭제 확인 팝업 표시 상태
    @State private var showDeleteConfirmation = false
    
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
               let url = URL(string: urlString),
               let data = try? Data(contentsOf: url),
               let uiImage = UIImage(data: data) {
                vm.profileImage = Image(uiImage: uiImage)
                vm.selectedImageData = data
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
                            Button(action: { showDeleteConfirmation = true }) {
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
                        isEditing: isEditing // 수정 모드 여부 전달
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
        viewModel.registerDog()
    }
    
    // 반려견 삭제 메서드
    private func deleteDog() {
        guard let dogId = initialDetail?.id else { return }
        
        viewModel.isLoading = true
        
        // API 호출을 통한 반려견 정보 삭제
        viewModel.deleteDog(dogId: dogId) { success in
            viewModel.isLoading = false
            
            if success {
                // 삭제 성공 시 화면 닫기
                dismiss()
                onComplete?()
            } else {
                // 삭제 실패 시 에러 메시지 표시
                viewModel.errorMessage = ErrorResponse(
                    statusCode: 500,
                    message: "반려견 정보 삭제 중 오류가 발생했습니다.",
                    error: "Unknown error",
                    success: false,
                    timestamp: ""
                )
            }
        }
    }
}

// MARK: - Preview
#Preview {
    RegisterDogView()
}

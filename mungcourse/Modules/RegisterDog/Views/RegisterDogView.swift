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
            vm.initialDetail = detail  // 초기 데이터 할당하여 변경 감지 기능이 작동하도록 설정
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
        NavigationStack { 
            ZStack { // 투명 배경으로 키보드 내리기 제스처 추가
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.endEditing()
                    }
                VStack(spacing: 0) {
                    CommonHeaderView(
                        leftIcon: showBackButton ? "arrow_back" : nil,
                        leftAction: showBackButton ? { dismiss() } : nil,
                        title: isEditing ? "반려견 정보 수정" : "반려견 정보 등록"
                    )
                    
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
                        buttonTitle: isEditing ? "수정하기" : "완료"
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
                .navigationBarHidden(true)
                .ignoresSafeArea(edges: .bottom)
                .onChange(of: viewModel.isRegistrationComplete) { _, isComplete in
                    if isComplete {
                        // 등록 완료 시 처리: 우선 dismiss, 그 후 parent에게도 알림
                        dismiss()
                        onComplete?()
                    }
                }
                .ignoresSafeArea() // 기타 설정
            }
        }
    }
    
    // MARK: - Computed Properties (Validation logic might stay here or move)
    private var isFormValid: Bool {
        !viewModel.name.isEmpty && viewModel.gender != nil && !viewModel.breed.isEmpty && !viewModel.weight.isEmpty
    }

    // MARK: - Actions (Registration logic stays in the main view)
    private func registerAction() {
        if isEditing, let id = initialDetail?.id {
            print("[RegisterDogView] 디버그: 수정 모드, updateDog 호출 id=\(id)")
            viewModel.updateDog(dogId: id)
        } else {
            print("[RegisterDogView] 디버그: 신규 등록 모드, registerDog 호출")
            viewModel.registerDog()
        }
    }
}

// MARK: - Preview
#Preview {
    RegisterDogView()
        .environmentObject(DogViewModel()) // Preview에 DogViewModel 추가
}

// 키보드 해제용 Extension
private extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

import SwiftUI
// TODO: PhotosUI import for image picker functionality
// TODO: Create a dedicated DogViewModel instead of using LoginViewModel

struct RegisterDogView: View {
    // TODO: Replace LoginViewModel with a dedicated DogViewModel
    @ObservedObject var viewModel: LoginViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State Variables (Managed by the main view)
    @State private var profileImage: Image? = nil
    @State private var name: String = ""
    @State private var gender: Gender? = nil
    @State private var breed: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var weight: String = ""
    @State private var isNeutered: Bool? = nil
    @State private var hasPatellarLuxationSurgery: Bool? = nil
    
    // TODO: Define Gender Enum (Keep here or move to a shared location)
    enum Gender: String, CaseIterable, Identifiable {
        case female = "여아"
        case male = "남아"
        var id: String { self.rawValue }
    }
    
    // MARK: - Body
    var body: some View {
        // NavigationStack might still be needed for the navigation context, 
        // but header is now custom.
        NavigationStack { 
            VStack(spacing: 0) { // Use spacing 0 if header shouldn't have gap below
                CommonHeaderView(
                    leftIcon: "arrow_back", // Use the back arrow icon asset
                    leftAction: { 
                        dismiss()
                    },
                    title: "반려견 정보 입력"
                ) { // Right content: The completion button
                    CommonFilledButton(
                        title: "완료",
                        action: registerAction,
                        isEnabled: isFormValid && !viewModel.isLoading
                    )
                    .frame(width: 60) // Adjust width as needed for header button
                }
                
                // The main content area
                RegisterDogContentsView(
                    profileImage: $profileImage,
                    name: $name,
                    gender: $gender,
                    breed: $breed,
                    dateOfBirth: $dateOfBirth,
                    weight: $weight,
                    isNeutered: $isNeutered,
                    hasPatellarLuxationSurgery: $hasPatellarLuxationSurgery,
                    errorMessage: viewModel.errorMessage?.message
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
            .onChange(of: viewModel.isLoggedIn) { isLoggedIn in
                if isLoggedIn {
                    // 로그인 완료 시 화면 닫기
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - Computed Properties (Validation logic might stay here or move)
    private var isFormValid: Bool {
        !name.isEmpty && gender != nil && !breed.isEmpty && !weight.isEmpty
    }

    // MARK: - Actions (Registration logic stays in the main view)
    private func registerAction() {
        guard let weightDouble = Double(weight) else {
            viewModel.errorMessage = IdentifiableError(message: "유효한 몸무게를 입력해주세요.")
            return
        }
        guard let selectedGender = gender else {
            viewModel.errorMessage = IdentifiableError(message: "성별을 선택해주세요.")
            return
        }
        
        // TODO: Calculate age from date of birth
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        let age = ageComponents.year ?? 0
        
        // 반려견 등록 호출
        viewModel.registerDog(name: name, age: age, breed: breed)
    }
}

// MARK: - Preview
#Preview {
    // Ensure LoginViewModel provides necessary states for preview
    RegisterDogView(viewModel: LoginViewModel())
} 
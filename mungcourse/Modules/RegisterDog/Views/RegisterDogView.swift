import SwiftUI
// TODO: PhotosUI import for image picker functionality
// TODO: Create a dedicated DogViewModel instead of using LoginViewModel

struct RegisterDogView: View {
    // TODO: Replace LoginViewModel with a dedicated DogViewModel
    @ObservedObject var viewModel: LoginViewModel
    // TODO: Add @Environment(\.dismiss) var dismiss for back button action
    
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
                        // TODO: Implement dismiss action
                        // dismiss()
                        print("Back button tapped")
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
                    errorMessage: viewModel.errorMessage
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
        }
    }
    
    // MARK: - Computed Properties (Validation logic might stay here or move)
    private var isFormValid: Bool {
        !name.isEmpty && gender != nil && !breed.isEmpty && !weight.isEmpty
    }

    // MARK: - Actions (Registration logic stays in the main view)
    private func registerAction() {
        guard let weightDouble = Double(weight) else {
            viewModel.errorMessage = "유효한 몸무게를 입력해주세요."
            return
        }
        guard let selectedGender = gender else {
            viewModel.errorMessage = "성별을 선택해주세요."
            return
        }
        
        // TODO: Update ViewModel function call signature
        
        // --- Placeholder Call (Remove when ViewModel is updated) ---
        print("Registering Dog:")
        print("- Name: \(name)")
        print("- Gender: \(selectedGender.rawValue)")
        print("- Breed: \(breed)")
        print("- DOB: \(dateOfBirth)")
        print("- Weight: \(weightDouble)")
        print("- Neutered: \(isNeutered != nil ? String(describing: isNeutered!) : "N/A")")
        print("- Surgery: \(hasPatellarLuxationSurgery != nil ? String(describing: hasPatellarLuxationSurgery!) : "N/A")")
        
        viewModel.isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            viewModel.isLoading = false
            viewModel.errorMessage = Bool.random() ? nil : "서버 오류로 등록에 실패했습니다."
        }
        // --- End Placeholder ---
    }
}

// MARK: - Preview
#Preview {
    // Ensure LoginViewModel provides necessary states for preview
    RegisterDogView(viewModel: LoginViewModel())
} 
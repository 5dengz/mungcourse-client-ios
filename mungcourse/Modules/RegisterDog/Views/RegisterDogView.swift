import SwiftUI
// TODO: PhotosUI import for image picker functionality
// TODO: Create a dedicated DogViewModel instead of using LoginViewModel

struct RegisterDogView: View {
    // TODO: Replace LoginViewModel with a dedicated DogViewModel
    @ObservedObject var viewModel: LoginViewModel
    
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
        NavigationStack {
            // Use the extracted content view
            RegisterDogContentsView(
                profileImage: $profileImage,
                name: $name,
                gender: $gender,
                breed: $breed,
                dateOfBirth: $dateOfBirth,
                weight: $weight,
                isNeutered: $isNeutered,
                hasPatellarLuxationSurgery: $hasPatellarLuxationSurgery,
                errorMessage: viewModel.errorMessage // Pass the error message
                // TODO: Pass any necessary actions (like add another dog)
            )
            .navigationTitle("반려견 정보 입력")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        registerAction()
                    }
                    .font(.custom("Pretendard-Bold", size: 18))
                    .foregroundColor(isFormValid ? Color("main") : Color("gray500"))
                    .disabled(!isFormValid || viewModel.isLoading)
                }
                // TODO: Add back button if needed
            }
            .overlay {
                if viewModel.isLoading {
                    Color.black.opacity(0.1).ignoresSafeArea()
                    ProgressView()
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
    RegisterDogView(viewModel: LoginViewModel())
} 
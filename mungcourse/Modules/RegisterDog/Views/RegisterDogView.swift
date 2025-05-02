import SwiftUI
// TODO: PhotosUI import for image picker functionality
import PhotosUI // Already added, but good practice to ensure
// TODO: Create a dedicated DogViewModel instead of using LoginViewModel

struct RegisterDogView: View {
    // LoginViewModel 대신 RegisterDogViewModel 사용
    @StateObject private var viewModel = RegisterDogViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State Variables (Managed by the main view)
    @State private var profileImage: Image? = nil
    @State private var selectedImageData: Data? = nil // State for selected image data
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
                    registerAction: registerAction
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
        viewModel.registerDog()
    }
}

// MARK: - Preview
#Preview {
    RegisterDogView()
}

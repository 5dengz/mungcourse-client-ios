import SwiftUI
// TODO: PhotosUI import for image picker functionality
// TODO: Create a dedicated DogViewModel instead of using LoginViewModel

struct RegisterDogView: View {
    // TODO: Replace LoginViewModel with a dedicated DogViewModel
    @ObservedObject var viewModel: LoginViewModel
    
    // MARK: - State Variables
    @State private var profileImage: Image? = nil // Placeholder for image selection
    @State private var name: String = ""
    @State private var gender: Gender? = nil // Use an Enum: Gender(female, male)
    @State private var breed: String = ""
    @State private var dateOfBirth: Date = Date() // Default to today, user should select
    @State private var weight: String = ""
    @State private var isNeutered: Bool? = nil
    @State private var hasPatellarLuxationSurgery: Bool? = nil
    
    // TODO: Define Gender Enum
    enum Gender: String, CaseIterable, Identifiable {
        case female = "여아"
        case male = "남아"
        var id: String { self.rawValue }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView { // Use ScrollView for potentially long content
                VStack(spacing: 24) { // Increased spacing
                    // Profile Image Section
                    ProfileImageView(image: $profileImage)

                    // Input Fields Section
                    VStack(spacing: 16) { // Group related fields
                        RequiredTextField(title: "이름", placeholder: "입력하기", text: $name)
                        RequiredSegmentedPicker(title: "성별", selection: $gender, options: Gender.allCases)
                        RequiredPickerField(title: "견종", placeholder: "선택하기", selection: $breed) // Consider making this a real Picker
                        RequiredDatePicker(title: "생년월일", selection: $dateOfBirth)
                        RequiredTextField(title: "몸무게(kg)", placeholder: "입력하기", text: $weight)
                            .keyboardType(.decimalPad) // Allow decimal for weight
                        OptionalSegmentedPicker(title: "중성화 여부", selection: $isNeutered)
                        OptionalSegmentedPicker(title: "슬개골 탈구 수술 여부", selection: $hasPatellarLuxationSurgery)
                    }
                    
                    // Error Message
                    if let error = viewModel.errorMessage {데
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption) // Smaller font for error
                    }

                    // Add Another Dog Button (Optional)
                    Button("다른 반려견 추가하기") {
                        // TODO: Implement action to add another dog
                    }
                    .font(.custom("Pretendard-Regular", size: 14))
                    .foregroundColor(Color("gray700")) // Use color from asset catalog
                    .padding(.top, 10)

                    Spacer() // Push content to top

                }
                .padding(.horizontal) // Add horizontal padding to the main VStack
                .padding(.bottom) // Add padding at the bottom for the button
            }
            .navigationTitle("반려견 정보 입력")
            .navigationBarTitleDisplayMode(.inline) // Center title
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        registerAction()
                    }
                    .font(.custom("Pretendard-Bold", size: 18)) // Custom font
                    .foregroundColor(isFormValid ? Color("main") : Color("gray500")) // Dynamic color
                    .disabled(!isFormValid || viewModel.isLoading)
                }
                // TODO: Add back button if needed
            }
            // Loading Indicator Overlay
            .overlay {
                if viewModel.isLoading {
                    Color.black.opacity(0.1).ignoresSafeArea() // Dim background
                    ProgressView()
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        !name.isEmpty && gender != nil && !breed.isEmpty && !weight.isEmpty // Add other required fields as needed
        // Date validation might be needed too
    }

    // MARK: - Actions
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
        // viewModel.registerDog(
        //     profileImage: profileImage, // Need to handle image data
        //     name: name,
        //     gender: selectedGender,
        //     breed: breed,
        //     dateOfBirth: dateOfBirth,
        //     weight: weightDouble,
        //     isNeutered: isNeutered,
        //     hasPatellarLuxationSurgery: hasPatellarLuxationSurgery
        // )
        
        // --- Placeholder Call (Remove when ViewModel is updated) ---
        print("Registering Dog:")
        print("- Name: \(name)")
        print("- Gender: \(selectedGender.rawValue)")
        print("- Breed: \(breed)")
        print("- DOB: \(dateOfBirth)")
        print("- Weight: \(weightDouble)")
        print("- Neutered: \(isNeutered != nil ? String(describing: isNeutered!) : "N/A")")
        print("- Surgery: \(hasPatellarLuxationSurgery != nil ? String(describing: hasPatellarLuxationSurgery!) : "N/A")")
        // Simulate registration process for now
         viewModel.isLoading = true
         DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
             viewModel.isLoading = false
             // On success: viewModel.errorMessage = nil; navigate away
             // On failure: viewModel.errorMessage = "등록 실패"
             viewModel.errorMessage = Bool.random() ? nil : "서버 오류로 등록에 실패했습니다." // Simulate random success/failure
         }
        // --- End Placeholder ---
    }
}

// MARK: - Reusable Subviews (Helper Components)

struct ProfileImageView: View {
    @Binding var image: Image?
    // TODO: Add logic to present image picker
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(Color("gray100")) // Use asset color
                .frame(width: 127, height: 127)
                .overlay(alignment: .center) {
                    // Display selected image or placeholder
                    if let img = image {
                        img
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "photo.fill") // Placeholder icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60)
                            .foregroundColor(Color("gray400"))
                    }
                }

            Button {
                // TODO: Add action to show image picker
                print("Select image tapped")
            } label: {
                ZStack {
                    Circle()
                        .fill(Color("gray600")) // Use asset color
                        .frame(width: 34, height: 34)
                    Image(systemName: "camera.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                }
            }
            .offset(x: 5, y: 5) // Adjust offset slightly
        }
        .padding(.vertical) // Add some vertical padding
    }
}

// --- Base Input Field Style ---
struct InputFieldContainer<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Pretendard-SemiBold", size: 16))
                .foregroundColor(Color("gray800")) // Use asset color
            content
        }
    }
}

struct InputBoxStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .frame(height: 41)
            .background(Color.white) // Or slightly off-white if needed
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("gray300"), lineWidth: 0.5) // Use asset color
            )
    }
}

// --- Specific Input Field Types ---

struct RequiredTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        InputFieldContainer(title: title) {
            TextField(placeholder, text: $text)
                .font(.custom("Pretendard-Regular", size: 14))
                .modifier(InputBoxStyle())
                .foregroundColor(text.isEmpty ? Color("gray500") : Color("black")) // Placeholder color
        }
    }
}

struct RequiredPickerField: View {
    let title: String
    let placeholder: String
    @Binding var selection: String // Replace with appropriate type if using a real Picker
    
    // TODO: Implement actual Picker functionality (e.g., navigate to a selection list)
    var body: some View {
        InputFieldContainer(title: title) {
            HStack {
                Text(selection.isEmpty ? placeholder : selection)
                    .font(.custom("Pretendard-Regular", size: 14))
                    .foregroundColor(selection.isEmpty ? Color("gray500") : Color("black"))
                Spacer()
                Image(systemName: "chevron.down") // Or chevron.right if navigating
                    .foregroundColor(Color("gray500"))
            }
            .modifier(InputBoxStyle())
            .contentShape(Rectangle()) // Make HStack tappable
            .onTapGesture {
                // TODO: Show picker view/options
                print("\(title) picker tapped")
            }
        }
    }
}


struct RequiredDatePicker: View {
    let title: String
    @Binding var selection: Date

    var body: some View {
         InputFieldContainer(title: title) {
             HStack {
                // Use DatePicker directly inline or as a button presenting a modal
                 DatePicker(
                    "", // No label needed here as we have the InputFieldContainer title
                    selection: $selection,
                    displayedComponents: [.date]
                 )
                 .labelsHidden() // Hide the default label
                 .font(.custom("Pretendard-Regular", size: 14))
                 .accentColor(Color("main")) // Picker accent color

                 Spacer() // Pushes date picker to the left
             }
             .modifier(InputBoxStyle()) // Apply consistent styling
         }
    }
}


// --- Segmented Pickers ---
struct SegmentedButton<T: Hashable>: View {
    let option: T
    @Binding var selection: T?
    let text: String

    var isSelected: Bool { selection == option }

    var body: some View {
        Button {
            selection = option
        } label: {
            Text(text)
                .font(.custom(isSelected ? "Pretendard-Bold" : "Pretendard-Regular", size: 14))
                .frame(maxWidth: .infinity)
                .frame(height: 41)
                .foregroundColor(isSelected ? .white : Color("gray600")) // Use asset colors
                .background(isSelected ? Color("main") : Color.clear) // Use asset colors
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.clear : Color("gray300"), lineWidth: 0.5) // Use asset colors
                )
        }
    }
}

struct RequiredSegmentedPicker<Option: RawRepresentable & Hashable & CaseIterable & Identifiable>: View where Option.RawValue == String {
    let title: String
    @Binding var selection: Option?
    let options: [Option] // Use the enum cases directly

    var body: some View {
        InputFieldContainer(title: title) {
            HStack(spacing: 12) { // Spacing between buttons
                ForEach(options) { option in
                     SegmentedButton(option: option, selection: $selection, text: option.rawValue)
                }
            }
        }
    }
}

struct OptionalSegmentedPicker: View {
    let title: String
    @Binding var selection: Bool?

    var body: some View {
        InputFieldContainer(title: title) {
            HStack(spacing: 12) {
                SegmentedButton(option: true, selection: $selection, text: "예")
                SegmentedButton(option: false, selection: $selection, text: "아니오")
            }
        }
    }
}


// MARK: - Preview
#Preview {
    // It's better to create a mock ViewModel for previews
    // or ensure LoginViewModel() has sensible defaults for this view.
    RegisterDogView(viewModel: LoginViewModel())
}
// ... existing code ...
// Note: The original Preview block is removed as it's replaced above.
// If you need to keep the original one as well, adjust accordingly.
// #Preview {
//     RegisterDogView(viewModel: LoginViewModel())
// } 
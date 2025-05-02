import SwiftUI

// MARK: - Extracted Content View
struct RegisterDogContentsView: View {
    // Bindings to the state variables in the parent view
    @Binding var profileImage: Image?
    @Binding var selectedImageData: Data?
    @Binding var name: String
    @Binding var gender: Gender?
    @Binding var breed: String
    @Binding var dateOfBirth: Date
    @Binding var weight: String
    @Binding var isNeutered: Bool?
    @Binding var hasPatellarLuxationSurgery: Bool?
    
    // Passed value
    let errorMessage: String?
    let isFormValid: Bool
    let isLoading: Bool
    var registerAction: () -> Void
    
    // TODO: Define actions passed from the parent if needed
    // var addAnotherDogAction: () -> Void
    
    var body: some View {
        ScrollView { 
            VStack(spacing: 24) {
                ProfileImageView(image: $profileImage, selectedImageData: $selectedImageData)

                VStack(spacing: 35) { 
                    RequiredTextField(title: "이름", placeholder: "입력하기", text: $name)
                    // Gender 타입 사용 (RegisterDogView.Gender 대신)
                    RequiredSegmentedPicker(title: "성별", selection: $gender, options: Gender.allCases)
                    RequiredPickerField(title: "견종", placeholder: "선택하기", selection: $breed)
                    RequiredDatePicker(title: "생년월일", selection: $dateOfBirth)
                    RequiredTextField(title: "몸무게(kg)", placeholder: "입력하기", text: $weight)
                        .keyboardType(.decimalPad)
                    OptionalSegmentedPicker(title: "중성화 여부", selection: $isNeutered)
                    OptionalSegmentedPicker(title: "슬개골 탈구 수술 여부", selection: $hasPatellarLuxationSurgery)
                }
                
                Button("다른 반려견 추가하기") {
                    // TODO: Call the action passed from parent
                    // addAnotherDogAction()
                    print("Add another dog tapped (in subview)")
                }
                .font(.custom("Pretendard-Regular", size: 14))
                .foregroundColor(Color("gray700"))
                .padding(.top, 29)
                
                CommonFilledButton(
                    title: "완료",
                    action: registerAction,
                    isEnabled: isFormValid && !isLoading
                )
                .padding(.top, 0)

                Spacer() // Keep spacer if needed within the scroll content
            }
            .padding(.bottom)
        }
    }
}

import SwiftUI

// MARK: - Extracted Content View
struct RegisterDogContentsView: View {
    // Bindings to the state variables in the parent view
    @Binding var profileImage: Image?
    @Binding var name: String
    @Binding var gender: RegisterDogView.Gender?
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
                ProfileImageView(image: $profileImage)

                VStack(spacing: 16) { 
                    RequiredTextField(title: "이름", placeholder: "입력하기", text: $name)
                    // Use fully qualified enum type name here
                    RequiredSegmentedPicker(title: "성별", selection: $gender, options: RegisterDogView.Gender.allCases)
                    RequiredPickerField(title: "견종", placeholder: "선택하기", selection: $breed)
                    RequiredDatePicker(title: "생년월일", selection: $dateOfBirth)
                    RequiredTextField(title: "몸무게(kg)", placeholder: "입력하기", text: $weight)
                        .keyboardType(.decimalPad)
                    OptionalSegmentedPicker(title: "중성화 여부", selection: $isNeutered)
                    OptionalSegmentedPicker(title: "슬개골 탈구 수술 여부", selection: $hasPatellarLuxationSurgery)
                }
                
                if let error = errorMessage { // Use the passed error message
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button("다른 반려견 추가하기") {
                    // TODO: Call the action passed from parent
                    // addAnotherDogAction()
                    print("Add another dog tapped (in subview)")
                }
                .font(.custom("Pretendard-Regular", size: 14))
                .foregroundColor(Color("gray700"))
                .padding(.top, 10)
                
                CommonFilledButton(
                    title: "완료",
                    action: registerAction,
                    isEnabled: isFormValid && !isLoading
                )
                .padding(.top, 12)

                Spacer() // Keep spacer if needed within the scroll content
            }
            .padding(.horizontal) 
            .padding(.bottom)
        }
    }
}

// TODO: Add Preview for RegisterDogContentsView if possible (needs mock bindings)
// #Preview {
//     // Need to provide mock bindings for preview
//     @State var profileImage: Image? = nil
//     @State var name: String = ""
//     @State var gender: RegisterDogView.Gender? = .female
//     @State var breed: String = "푸들"
//     @State var dateOfBirth: Date = Date()
//     @State var weight: String = "5.5"
//     @State var isNeutered: Bool? = true
//     @State var hasPatellarLuxationSurgery: Bool? = false
//     let errorMessage: String? = "미리보기 에러 메시지"
//     
//     return RegisterDogContentsView(
//         profileImage: $profileImage,
//         name: $name,
//         gender: $gender,
//         breed: $breed,
//         dateOfBirth: $dateOfBirth,
//         weight: $weight,
//         isNeutered: $isNeutered,
//         hasPatellarLuxationSurgery: $hasPatellarLuxationSurgery,
//         errorMessage: errorMessage,
//         isFormValid: true,
//         isLoading: false,
//         registerAction: {}
//     )
// } 

import SwiftUI
import UIKit

// MARK: - 키보드 숨김 수정자
struct DismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(DismissKeyboardOnTap())
    }
}

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
    // 수정 모드 여부 (첫 로그인이 아닌 경우)
    let isEditing: Bool
    // 추가: S3 objectKey와 viewModel
    let objectKey: String?
    let viewModel: RegisterDogViewModel
    let buttonTitle: String // 추가

    // TODO: Define actions passed from the parent if needed
    // var addAnotherDogAction: () -> Void
    
    var body: some View {
        ZStack {
            // 배경 영역 - 터치하면 키보드가 내려감
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
                .ignoresSafeArea(.all, edges: .all)
            
            ScrollView {
                // 스크롤 배경 - 터치하면 키보드가 내려감
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.endEditing()
                    }
                    .allowsHitTesting(true)
            VStack(spacing: 24) {
                ProfileImageView(
                    image: $profileImage,
                    selectedImageData: $selectedImageData,
                    objectKey: objectKey,
                    viewModel: viewModel
                )

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
                
                CommonFilledButton(
                    title: buttonTitle,
                    action: registerAction,
                    isEnabled: isFormValid && !isLoading
                )
                .padding(.top, 16)

                Spacer() // Keep spacer if needed within the scroll content
            }
            .padding(.bottom)
        }
        .scrollDismissesKeyboard(.immediately) // 스크롤 시 키보드 즉시 내림
        .scrollIndicators(.hidden) // 스크롤바 숨김 처리
        .dismissKeyboardOnTap() // 커스텀 수정자 적용
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    UIApplication.shared.endEditing()
                }
        )
    }
}
}

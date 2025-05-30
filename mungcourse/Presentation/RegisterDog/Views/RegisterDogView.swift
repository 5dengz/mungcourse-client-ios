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
    // 로그아웃 처리 클로저 (기본 nil)
    var onLogout: (() -> Void)? = nil
    // 뒤로가기 버튼 노출 여부
    var showBackButton: Bool = true
    // 상단 SafeArea 높이를 저장하는 변수
    @State private var topSafeAreaHeight: CGFloat = 0
    // 로그아웃 확인 알림창 표시 여부
    @State private var showLogoutAlert: Bool = false
    // 로그인 필요 알림창 표시 여부
    @State private var showLoginAlert: Bool = false
    // 로그인 필요 알림 메시지
    @State private var loginErrorMessage: String = "로그인이 필요합니다"
    
    // 수정 모드 여부 계산
    private var isEditing: Bool {
        initialDetail != nil
    }
    
    // MARK: - Initializer
    init(initialDetail: DogRegistrationResponseData? = nil,
         onComplete: (() -> Void)? = nil,
         onLogout: (() -> Void)? = nil,
         showBackButton: Bool = true) {
        self.initialDetail = initialDetail
        self.onComplete = onComplete
        self.onLogout = onLogout
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
        ZStack {
            // 키보드 내리기 제스처는 VStack 내부에 추가하여 헤더와 충돌하지 않게 함
            VStack(spacing: 0) {
                CommonHeaderView(
                    leftIcon: showBackButton ? "arrow_back" : "arrow_back",
                    leftAction: showBackButton ? { dismiss() } : { showLogoutAlert = true },
                    title: isEditing ? "반려견 정보 수정" : "반려견 정보 등록"
                )
                .alert(isPresented: $showLogoutAlert) {
                    Alert(
                        title: Text("로그아웃"),
                        message: Text("로그아웃 하시겠습니까?"),
                        primaryButton: .destructive(Text("확인")) {
                            TokenManager.shared.clearTokens()
                            dismiss()
                            onLogout?()
                        },
                        secondaryButton: .cancel(Text("취소"))
                    )
                }
                .padding(.top, topSafeAreaHeight > 0 ? topSafeAreaHeight : 16)
                .zIndex(1) // 헤더가 터치 이벤트를 우선 받도록 합니다
                
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
            // 키보드 내리기 제스처 구현
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .overlay { // Apply overlay to the VStack
                if viewModel.isLoading {
                    Color.black.opacity(0.1).ignoresSafeArea()
                    ProgressView()
                }
            }
            .navigationBarHidden(true)
            .ignoresSafeArea(edges: .bottom)
            .overlay(
                GeometryReader { _ in
                    Color.clear
                        .onAppear {
                            DispatchQueue.main.async {
                                // iOS 15 이상에서 권장되는 방식 사용
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = windowScene.windows.first {
                                    topSafeAreaHeight = window.safeAreaInsets.top
                                    print("[RegisterDogView] measured topSafeAreaHeight: \(topSafeAreaHeight)")
                                }
                            }
                        }
                }
            )
            .onChange(of: viewModel.isRegistrationComplete) { _, isComplete in
                if isComplete {
                    // 등록 완료 시 토큰 유효성 확인 후 처리
                    if let token = TokenManager.shared.getAccessToken(), !token.isEmpty {
                        print("[RegisterDogView] 등록 완료: 토큰 확인 성공 - \(token.prefix(10))...")
                        
                        // 토큰 유효성 확인 한번 더
                        TokenManager.shared.validateTokens()
                        
                        // 등록 완료 시 처리: 우선 dismiss, 그 후 parent에게도 알림
                        dismiss()
                        
                        // 토큰 상태를 한번 더 확인하고 콜백 호출
                        DispatchQueue.main.async {
                            if TokenManager.shared.validateTokens() {
                                print("[RegisterDogView] onComplete 콜백 호출 전 토큰 확인 성공")
                                onComplete?()
                            } else {
                                print("[RegisterDogView] ⚠️ 경고: onComplete 콜백 호출 전 토큰 확인 실패")
                                // 토큰 상태에 상관없이 콜백은 호출하여 화면 전환
                                onComplete?()
                            }
                        }
                    } else {
                        print("[RegisterDogView] ⚠️ 경고: 등록 완료됐으나 토큰이 없거나 비어있음")
                        // 토큰 상태에 상관없이 dismiss 및 콜백 호출
                        dismiss()
                        onComplete?()
                    }
                }
            }
            .ignoresSafeArea() // 기타 설정
        }
        // 화면 나타날 때 토큰 검증
        .onAppear {
            verifyTokenAndProceed()
        }
        // 로그인 필요 알림
        .alert("로그인 필요", isPresented: $showLoginAlert) {
            Button("확인") {
                resetToLoginScreen()
            }
        } message: {
            Text(loginErrorMessage)
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
        } else if isEditing {
            print("[RegisterDogView] 에러: 수정 모드인데 ID가 없음")
            // ID가 없는 경우에도 로그만 남기고 수정 로직 실행 (예외 처리)
            if let dogId = dogVM.mainDog?.id {
                print("[RegisterDogView] 대체 ID 사용: \(dogId)")
                viewModel.updateDog(dogId: dogId)
            } else {
                print("[RegisterDogView] 메인 반려견 ID도 없어 신규 등록으로 처리")
                viewModel.registerDog()
            }
        } else {
            print("[RegisterDogView] 디버그: 신규 등록 모드, registerDog 호출")
            viewModel.registerDog()
        }
    }
}

// 키보드 해제용 Extension
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - 토큰 검증 및 로그인 화면 리셋 관련 메서드
extension RegisterDogView {
    // 토큰 검증 수행 메서드
    private func verifyTokenAndProceed() {
        if !TokenManager.shared.validateTokens() {
            // 토큰이 유효하지 않은 경우 갱신 시도
            print("[RegisterDogView] 토큰 유효하지 않음, 갱신 시도")
            TokenManager.shared.refreshAccessToken { success in
                if !success {
                    DispatchQueue.main.async {
                        self.loginErrorMessage = "로그인이 만료되었습니다. 다시 로그인해주세요."
                        self.showLoginAlert = true
                    }
                } else {
                    print("[RegisterDogView] 토큰 갱신 성공")
                }
            }
        } else {
            print("[RegisterDogView] 토큰 검증 성공")
        }
    }
    
    // 로그인 화면으로 리셋
    private func resetToLoginScreen() {
        // 토큰 클리어
        TokenManager.shared.clearTokens()
        
        // 앱 데이터 리셋 알림 발생
        NotificationCenter.default.post(name: .appDataDidReset, object: nil)
        
        // 현재 화면 닫기
        dismiss()
    }
}

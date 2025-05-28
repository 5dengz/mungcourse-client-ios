import SwiftUI

struct UserInfo: Codable, Identifiable {
    let sub: String
    let email: String
    let name: String?
    let provider: String?
    let userImgUrl: String?
    
    var id: String { sub }
    var nickname: String? { name }
    var profileImageUrl: String? { userImgUrl }
}

struct APIResponse<T: Codable>: Codable {
    let statusCode: Int
    let message: String
    let data: T
    let timestamp: String
    let success: Bool
}

struct ErrorResponse: Codable {
    let statusCode: Int
    let message: String
    let error: String?
    let success: Bool
    let timestamp: String
}

class ProfileViewModel: ObservableObject {
    @Published var userInfo: UserInfo?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var rawResponse: String? // 추가: 원본 응답 저장
    
    private static var apiBaseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? ""
    }
    
    func fetchUserInfo() {
        isLoading = true
        errorMessage = nil
        guard TokenManager.shared.getAccessToken() != nil,
              TokenManager.shared.getRefreshToken() != nil else {
            errorMessage = "토큰이 없습니다. 다시 로그인 해주세요."
            isLoading = false
            print("[ProfileViewModel] 토큰 없음")
            return
        }
        guard let url = URL(string: "\(Self.apiBaseURL)/v1/auth/me") else {
            errorMessage = "URL 생성 실패"
            isLoading = false
            print("[ProfileViewModel] URL 생성 실패")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        NetworkManager.shared.performAPIRequest(request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("[ProfileViewModel] 네트워크 에러: \(error.localizedDescription)")
                    return
                }
                guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "데이터 없음"
                    print("[ProfileViewModel] 데이터 없음")
                    return
                }
                print("[ProfileViewModel] 응답 데이터: \(String(data: data, encoding: .utf8) ?? "데이터 디코딩 실패")")
                do {
                    if (200...299).contains(httpResponse.statusCode) {
                        let response = try JSONDecoder().decode(APIResponse<UserInfo>.self, from: data)
                        self.userInfo = response.data
                        print("[ProfileViewModel] 유저 정보 파싱 성공: \(response.data)")
                        self.rawResponse = String(data: data, encoding: .utf8)
                    } else {
                        let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        self.errorMessage = errorResponse.message
                        print("[ProfileViewModel] 에러 응답 파싱: \(errorResponse)")
                        self.rawResponse = String(data: data, encoding: .utf8)
                    }
                } catch let decodingError as DecodingError {
                    print("[ProfileViewModel] 디코딩 에러: \(decodingError)")
                    self.errorMessage = "데이터 파싱 실패: \(decodingError.localizedDescription)"
                } catch {
                    self.errorMessage = error.localizedDescription
                    print("[ProfileViewModel] 알 수 없는 에러: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct ProfileTabView: View {
    let tabBarHeight: CGFloat
    @EnvironmentObject var dogVM: DogViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedTab: ProfileTabSelectorView.InfoTab = .basic
    @State private var showSettings = false
    @State private var showSelectDog = false
    @State private var showAddDog = false
    @State private var showEditDog = false
    @State private var showDeleteConfirmation = false
    @State private var showLastDogAlert = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // 헤더
                CommonHeaderView(
                    leftIcon: "",
                    leftAction: { /* 뒤로가기 액션 */ },
                    title: "프로필"
                ) {
                    HStack(spacing: 16) {
                        // 반려견 추가 버튼
                        Button(action: { showAddDog = true }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(Color("gray700"))
                        }
                        // 삭제(쓰레기통) 버튼
                        Button(action: {
                            if dogVM.dogs.count <= 1 {
                                showLastDogAlert = true
                            } else {
                                showDeleteConfirmation = true
                            }
                        }) {
                            Image(systemName: "trash")
                                .font(.title2)
                                .foregroundColor(Color("gray700"))
                        }
                        // 설정 버튼
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape")
                                .font(.title2)
                                .foregroundColor(Color("gray700"))
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 16)
                // 프로필 영역
                ProfileSectionView(
                    nickname: dogVM.mainDog?.name,
                    profileImageUrl: dogVM.mainDog?.dogImgUrl,
                    onEdit: {
                        Task {
                            if let id = dogVM.mainDog?.id {
                                await dogVM.fetchDogDetail(id)
                            }
                            showEditDog = true
                        }
                    }
                )
                .padding(.bottom, 24)
                // 탭 선택자
                ProfileTabSelectorView(selectedTab: $selectedTab)
                    .padding(.bottom, 24)
                // 정보 영역
                ProfileInfoSectionView(selectedTab: selectedTab, tabBarHeight: tabBarHeight)
                Spacer()
            }
            // 삭제 확인 팝업
            if showDeleteConfirmation {
                CommonPopupModal(
                    title: "반려견 정보 삭제",
                    message: "정보 삭제 시 반려견 정보 및 산책 기록은 모두 삭제되어 복구할 수 없습니다.\n\n정말 삭제하시겠어요?",
                    cancelText: "취소",
                    confirmText: "삭제",
                    cancelAction: { showDeleteConfirmation = false },
                    confirmAction: {
                        deleteMainDog()
                        showDeleteConfirmation = false
                    }
                )
            }
        }
        // 유일한 프로필 삭제 불가 알림
        .alert("삭제 불가", isPresented: $showLastDogAlert) {
            Button("확인") {}
        } message: {
            Text("유일한 프로필은 삭제할 수 없습니다.")
        }
        .onAppear {
            viewModel.fetchUserInfo()
            Task {
                if let dogId = dogVM.mainDog?.id {
                    // 상세 정보 및 산책 기록 조회
                    await dogVM.fetchDogDetail(dogId)
                    await dogVM.fetchWalkRecords(dogId)
                }
            }
        }
        // 메인 반려견이 변경될 때마다 상세 정보 및 산책 기록 재요청
        .onChange(of: dogVM.mainDog) { oldValue, newMain in
            if let id = newMain?.id {
                Task {
                    await dogVM.fetchDogDetail(id)
                    await dogVM.fetchWalkRecords(id)
                }
            }
        }
        // 설정 화면
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
        }
        // 반려견 추가 화면
        .fullScreenCover(isPresented: $showAddDog) {
            RegisterDogView(onComplete: {
                dogVM.fetchDogs()
            }, showBackButton: true)
            .environmentObject(dogVM)
        }
        // 반려견 편집 화면
        .fullScreenCover(isPresented: $showEditDog) {
            if let detail = dogVM.dogDetail {
                RegisterDogView(initialDetail: detail, onComplete: {
                    print("[ProfileTabView] 강아지 정보 수정 완료")
                    // 모든 강아지 다시 가져오기
                    dogVM.fetchDogs()
                    
                    // 강아지 정보 변경된 강아지가 현재 mainDog/selectedDog인 경우 업데이트
                    if dogVM.mainDog?.id == detail.id {
                        print("[ProfileTabView] 메인 강아지 정보 변경 감지. 다시 가져오기 시도")
                        Task {
                            try? await dogVM.fetchMainDog()
                            print("[ProfileTabView] 메인 강아지 새로 가져오기 완료")
                        }
                    }
                }, showBackButton: true)
                .environmentObject(dogVM)
            } else {
                ProgressView()
            }
        }
        // 반려견 선택 화면
        .fullScreenCover(isPresented: $showSelectDog) {
            DogSelectionView(
                showHeader: false,
                showAddDogButton: true,
                showCompleteButton: false,
                immediateSelection: true
            )
                .environmentObject(dogVM)
        }
    }
    
    // MARK: - 삭제 로직
    private func deleteMainDog() {
        guard let id = dogVM.mainDog?.id else { return }
        print("[ProfileTabView] 강아지 삭제 시작 (ID: \(id))")
        
        Task {
            do {
                // 1. 강아지 삭제 API 호출
                try await DogService.shared.deleteDog(dogId: id)
                print("[ProfileTabView] 강아지 삭제 성공 (ID: \(id))")
                
                // 2. 로컬 dogs 상태 수정 (강아지 목록에서 삭제된 강아지 제거)
                let remainingDogs = dogVM.dogs.filter { $0.id != id }
                
                // 3. 다음 대표 강아지 찾기
                if let serverMain = remainingDogs.first(where: { $0.isMain }) {
                    // 3-1. 서버에서 지정된 대표 강아지가 있는 경우
                    print("[ProfileTabView] 서버 지정 대표 강아지 발견: \(serverMain.name)")
                    dogVM.mainDog = serverMain
                    dogVM.selectedDog = serverMain
                    dogVM.selectedDogName = serverMain.name
                } else if let first = remainingDogs.first {
                    // 3-2. 대표가 지정되지 않은 경우 첫 번째 강아지를 대표로 설정
                    print("[ProfileTabView] 새 대표 강아지로 \(first.name) 설정 시도")
                    Task {
                        let success = await dogVM.setMainDog(first.id)
                        print("[ProfileTabView] 새 대표 강아지 설정 \(success ? "성공" : "실패")")
                    }
                } else {
                    // 3-3. 강아지가 모두 삭제된 경우
                    print("[ProfileTabView] 모든 강아지가 삭제되었습니다.")
                    dogVM.mainDog = nil
                    dogVM.selectedDog = nil
                    dogVM.selectedDogName = ""
                }
                
                // 4. 서버에서 새로 목록 가져오기
                dogVM.fetchDogs {
                    print("[ProfileTabView] 강아지 목록 다시 가져오기 완료")
                    // 추가 작업 필요 시 여기서 처리
                }
            } catch {
                print("[ProfileTabView] 강아지 삭제 오류:", error)
            }
        }
    }
}

#Preview {
    ProfileTabView(tabBarHeight: 0)
        .environmentObject(DogViewModel())
}

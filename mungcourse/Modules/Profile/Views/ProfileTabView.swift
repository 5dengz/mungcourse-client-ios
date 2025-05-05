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
    @EnvironmentObject var dogVM: DogViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedTab: ProfileTabSelectorView.InfoTab = .basic
    @State private var showSettings = false
    @State private var showSelectDog = false
    @State private var showEditDog = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // 헤더
                CommonHeaderView(
                    leftIcon: "",
                    leftAction: { /* 뒤로가기 액션 */ },
                    title: "프로필"
                ) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                            .font(.title2)
                            .foregroundColor(.primary)
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
                    },
                    onTapImage: { showSelectDog = true }
                )
                .padding(.bottom, 24)
                // 탭 선택자
                ProfileTabSelectorView(selectedTab: $selectedTab)
                    .padding(.bottom, 24)
                // 정보 영역
                ProfileInfoSectionView(selectedTab: selectedTab)
                Spacer()
            }
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
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showEditDog) {
            // 프로필 편집 (현재 강아지 정보로 초기화)
            if let detail = dogVM.dogDetail {
                RegisterDogView(initialDetail: detail, onComplete: {
                    // 완료 후 강아지 목록 새로고침 및 메인 강아지 재설정
                    dogVM.fetchDogs()
                    // 삭제 후 남은 강아지가 있으면 첫 번째 강아지를 메인으로 설정
                    if let firstDog = dogVM.dogs.first {
                        dogVM.mainDog = firstDog
                    } else {
                        // 모든 강아지가 삭제된 경우 (이론상 RegisterDogView에서 막지만 방어 코드)
                        // 필요하다면 사용자에게 알리거나 다른 처리
                        print("모든 강아지가 삭제되었습니다.")
                        dogVM.mainDog = nil
                        // TODO: UI에서 안내 메시지 또는 등록 화면으로 이동 처리
                    }
                }, showBackButton: true)
                    .environmentObject(dogVM)
            } else {
                RegisterDogView(onComplete: {
                    // 신규 등록 후에도 목록 새로고침 및 메인 설정 (필요시)
                    dogVM.fetchDogs()
                    if let firstDog = dogVM.dogs.first, dogVM.mainDog == nil {
                        dogVM.mainDog = firstDog
                    }
                }, showBackButton: true)
                    .environmentObject(dogVM)
            }
        }
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
}

#Preview {
    ProfileTabView()
        .environmentObject(DogViewModel())
}

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
        guard let accessToken = TokenManager.shared.getAccessToken(),
              let refreshToken = TokenManager.shared.getRefreshToken() else {
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
    @Binding var showingDogSelection: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // 헤더
                CommonHeaderView(
                    leftIcon: "chevron.left",
                    leftAction: { /* 뒤로가기 액션 */ },
                    title: "프로필"
                ) {
                    HStack(spacing: 16) {
                        Button(action: { showingDogSelection = true }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                        Button(action: { /* 설정 액션 */ }) {
                            Image(systemName: "gearshape")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 16)
                // 프로필 영역
                ProfileSectionView(
                    nickname: dogVM.mainDog?.name,
                    profileImageUrl: dogVM.mainDog?.dogImgUrl,
                    onEdit: { /* 프로필 편집 액션 */ }
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
        }
    }
}

#Preview {
    ProfileTabView(showingDogSelection: .constant(false))
        .environmentObject(DogViewModel())
}

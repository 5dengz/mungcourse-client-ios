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

class ProfileViewModel: ObservableObject {
    @Published var userInfo: UserInfo?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var rawResponse: String? // 추가: 원본 응답 저장
    
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
        guard let url = URL(string: "https://api.mungcourse.online/v1/auth/me") else {
            errorMessage = "URL 생성 실패"
            isLoading = false
            print("[ProfileViewModel] URL 생성 실패")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(refreshToken, forHTTPHeaderField: "Authorization-Refresh")
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("[ProfileViewModel] 네트워크 에러: \(error.localizedDescription)")
                    return
                }
                guard let data = data else {
                    self.errorMessage = "데이터 없음"
                    print("[ProfileViewModel] 데이터 없음")
                    return
                }
                print("[ProfileViewModel] 응답 데이터: \(String(data: data, encoding: .utf8) ?? "데이터 디코딩 실패")")
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(APIResponse<UserInfo>.self, from: data)
                    self.userInfo = response.data
                    print("[ProfileViewModel] 유저 정보 파싱 성공: \(response.data)")
                    self.rawResponse = String(data: data, encoding: .utf8)
                } catch {
                    self.errorMessage = error.localizedDescription
                    print("[ProfileViewModel] 디코딩 에러: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}

struct ProfileTabView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedTab: ProfileTabSelectorView.InfoTab = .basic
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            ProfileHeaderView(
                onBack: { /* 뒤로가기 액션 */ },
                onSwitchProfile: { /* 프로필 전환 액션 */ },
                onSettings: { /* 설정 액션 */ }
            )
            .padding(.top, 8)
            .padding(.bottom, 16)
            // 프로필 영역
            ProfileSectionView(
                nickname: viewModel.userInfo?.nickname,
                profileImageUrl: viewModel.userInfo?.profileImageUrl,
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
        .onAppear {
            viewModel.fetchUserInfo()
        }
    }
}

#Preview {
    ProfileTabView()
}

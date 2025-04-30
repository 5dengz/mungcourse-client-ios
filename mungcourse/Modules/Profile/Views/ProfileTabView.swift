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
    @State private var selectedTab: InfoTab = .basic
    
    enum InfoTab: String, CaseIterable {
        case basic = "기본 정보"
        case walk = "산책 기록"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            headerView
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 16)
            // 프로필 영역
            profileSection
                .padding(.bottom, 24)
            // 버튼 영역
            tabSelector
                .padding(.bottom, 24)
            // 정보 영역
            infoSection
            Spacer()
        }
        .onAppear {
            viewModel.fetchUserInfo()
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: { /* 뒤로가기 액션 */ }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            Text("프로필")
                .font(.headline)
                .frame(maxWidth: .infinity)
            Button(action: { /* 프로필 전환 액션 */ }) {
                Text("프로필 전환")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            Button(action: { /* 설정 액션 */ }) {
                Image(systemName: "gearshape")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
        .frame(height: 51)
    }
    
    // MARK: - Profile Section
    private var profileSection: some View {
        VStack(spacing: 8) {
            if let user = viewModel.userInfo, let urlStr = user.profileImageUrl, let url = URL(string: urlStr) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Circle().fill(Color.gray.opacity(0.2))
                }
                .frame(width: 127, height: 127)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 127, height: 127)
            }
            Text(viewModel.userInfo?.nickname ?? "강아지 이름")
                .font(.title2)
                .fontWeight(.semibold)
            Button(action: { /* 프로필 편집 액션 */ }) {
                Text("프로필 편집")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 12) {
            ForEach(InfoTab.allCases, id: \ .self) { tab in
                Button(action: { selectedTab = tab }) {
                    Text(tab.rawValue)
                        .font(.subheadline)
                        .fontWeight(selectedTab == tab ? .bold : .regular)
                        .foregroundColor(selectedTab == tab ? .white : .primary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(
                            Group {
                                if selectedTab == tab {
                                    Capsule().fill(Color.accentColor)
                                } else {
                                    Capsule().fill(Color.clear)
                                }
                            }
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Info Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if selectedTab == .basic {
                Section(header: Text("기본 정보").font(.headline)) {
                    // 기본 정보 내용 (추후 구현)
                    Text("기본 정보 영역")
                        .foregroundColor(.secondary)
                }
            } else {
                Section(header: Text("산책 기록").font(.headline)) {
                    // 산책 기록 내용 (추후 구현)
                    Text("산책 기록 영역")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ProfileTabView()
}

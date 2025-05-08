import SwiftUI

struct ProfileInfoSectionView: View {
    let selectedTab: ProfileTabSelectorView.InfoTab
    let tabBarHeight: CGFloat
    @EnvironmentObject var dogVM: DogViewModel
    
    // 토큰이 유효한지 확인하는 계산 속성 추가
    private var isTokenAvailable: Bool {
        return TokenManager.shared.getAccessToken() != nil && 
               TokenManager.shared.getRefreshToken() != nil
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !isTokenAvailable {
                    // 토큰이 없을 때 표시할 뷰
                    Text("로그아웃 되었습니다.")
                        .font(.custom("Pretendard-Regular", size: 14))
                        .foregroundColor(Color("gray500"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 30)
                } else if selectedTab == .basic {
                    BasicInfoView(tabBarHeight: tabBarHeight)
                } else {
                    WalkRecordView(tabBarHeight: tabBarHeight)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, tabBarHeight)
        }
    }
}
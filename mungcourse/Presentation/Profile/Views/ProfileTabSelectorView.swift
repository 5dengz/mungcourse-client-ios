import SwiftUI

struct ProfileTabSelectorView: View {
    enum InfoTab: String, CaseIterable {
        case basic = "기본 정보"
        case walk = "산책 기록"
    }
    @Binding var selectedTab: InfoTab
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            // 배경 컨테이너
            ZStack {
                // 전체 경계 원형 테두리
                RoundedRectangle(cornerRadius: 26)
                    .foregroundColor(.clear)
                    .frame(width: 184, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .inset(by: 0.5)
                            .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.5)
                    )
                    
                // 선택된 배경 캡슐
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color("main"))
                    .frame(width: 92, height: 40)
                    .offset(x: selectedTab == .basic ? -46 : 46)
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                
                // 버튼 컨테이너
                HStack(spacing: 0) {
                    // 기본 정보 버튼
                    Button(action: {
                        withAnimation(.easeInOut) {
                            selectedTab = .basic
                        }
                    }) {
                        Text("기본 정보")
                            .font(Font.custom("Pretendard", size: 14))
                            .fontWeight(selectedTab == .basic ? .bold : .regular)
                            .foregroundColor(selectedTab == .basic ? Color("pointwhite") : Color("main"))
                            .frame(width: 92, height: 40)
                    }
                    
                    // 산책 기록 버튼
                    Button(action: {
                        withAnimation(.easeInOut) {
                            selectedTab = .walk
                        }
                    }) {
                        Text("산책 기록")
                            .font(Font.custom("Pretendard", size: 14))
                            .fontWeight(selectedTab == .walk ? .bold : .regular)
                            .foregroundColor(selectedTab == .walk ? Color("pointwhite") : Color("main"))
                            .frame(width: 92, height: 40)
                    }
                }
            }
        }
        .frame(width: 184, height: 40)
    }
}
import SwiftUI

struct ProfileTabSelectorView: View {
    enum InfoTab: String, CaseIterable {
        case basic = "기본 정보"
        case walk = "산책 기록"
    }
    @Binding var selectedTab: InfoTab
    @Namespace private var animation
    var body: some View {
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
                .frame(width: 102, height: 40)
                .offset(x: selectedTab == .basic ? -41 : 46)

            // 기본 정보 텍스트
            Text("기본 정보")
                .font(Font.custom("Pretendard", size: 14))
                .fontWeight(selectedTab == .basic ? .bold : .regular)
                .lineSpacing(19.6)
                .foregroundColor(selectedTab == .basic ? .white : Color("main"))
                .frame(width: 52, height: 20)
                .offset(x: -41)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        selectedTab = .basic
                    }
                }
            // 산책 기록 텍스트
            Text("산책 기록")
                .font(Font.custom("Pretendard", size: 14))
                .fontWeight(selectedTab == .walk ? .bold : .regular)
                .lineSpacing(19.6)
                .foregroundColor(selectedTab == .walk ? .white : Color("main"))
                .frame(width: 52, height: 20)
                .offset(x: 46)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        selectedTab = .walk
                    }
                }
        }
        .frame(width: 184, height: 40)
    }
}
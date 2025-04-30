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
            // Outer capsule with corner radius 26
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white)
            // Texts spaced by 35, with highlight behind selected text
            HStack(spacing: 35) {
                ForEach(InfoTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue)
                        .font(.subheadline)
                        .fontWeight(selectedTab == tab ? .bold : .regular)
                        .foregroundColor(selectedTab == tab ? .white : Color("main"))
                        .background(
                            Group {
                                if selectedTab == tab {
                                    RoundedRectangle(cornerRadius: 26)
                                        .fill(Color("main"))
                                        .frame(height: 40)
                                        .matchedGeometryEffect(id: "tabSlide", in: animation)
                                }
                            }
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                selectedTab = tab
                            }
                        }
                }
            }
        }
        .frame(width: 184, height: 40)
    }
}
import SwiftUI

struct ProfileTabSelectorView: View {
    enum InfoTab: String, CaseIterable {
        case basic = "기본 정보"
        case walk = "산책 기록"
    }
    @Binding var selectedTab: InfoTab
    var body: some View {
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
}
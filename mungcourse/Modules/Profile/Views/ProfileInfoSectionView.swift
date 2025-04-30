import SwiftUI

struct ProfileInfoSectionView: View {
    let selectedTab: ProfileTabSelectorView.InfoTab
    var body: some View {
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
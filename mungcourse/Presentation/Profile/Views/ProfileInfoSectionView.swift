import SwiftUI

struct ProfileInfoSectionView: View {
    let selectedTab: ProfileTabSelectorView.InfoTab
    let tabBarHeight: CGFloat
    @EnvironmentObject var dogVM: DogViewModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if selectedTab == .basic {
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
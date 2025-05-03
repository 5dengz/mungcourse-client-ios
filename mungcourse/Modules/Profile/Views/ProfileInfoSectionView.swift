import SwiftUI

struct ProfileInfoSectionView: View {
    let selectedTab: ProfileTabSelectorView.InfoTab
    @EnvironmentObject var dogVM: DogViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if selectedTab == .basic {
                BasicInfoView()
            } else {
                WalkRecordView()
            }
        }
        .padding(.horizontal)
    }
}
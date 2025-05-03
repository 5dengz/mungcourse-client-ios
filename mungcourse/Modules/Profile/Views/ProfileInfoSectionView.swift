import SwiftUI

struct ProfileInfoSectionView: View {
    let selectedTab: ProfileTabSelectorView.InfoTab
    @EnvironmentObject var dogVM: DogViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if selectedTab == .basic {
                Section(header: Text("기본 정보").font(.headline)) {
                    BasicInfoView()
                }
            } else {
                Section(header: Text("산책 기록").font(.headline)) {
                    WalkRecordView()
                }
            }
        }
        .padding(.horizontal)
    }
}
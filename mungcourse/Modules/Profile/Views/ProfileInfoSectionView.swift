import SwiftUI

struct ProfileInfoSectionView: View {
    let selectedTab: ProfileTabSelectorView.InfoTab
    @EnvironmentObject var dogVM: DogViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if selectedTab == .basic {
                Section(header: Text("기본 정보").font(.headline)) {
                    VStack(spacing: 0) {
                        HStack {
                            Text("견종/성별")
                            Spacer()
                            Text("말티즈/여아")
                        }
                        Divider()
                        HStack {
                            Text("생년월일")
                            Spacer()
                            Text("2012.04.03")
                        }
                        Divider()
                        HStack {
                            Text("체중")
                            Spacer()
                            Text("3.2kg")
                        }
                        Divider()
                        HStack {
                            Text("중성화 여부")
                            Spacer()
                            Text("예")
                        }
                        Divider()
                        HStack {
                            Text("슬개골 탈골 수술 여부")
                            Spacer()
                            Text("예")
                        }
                    }
                    .padding()
                    .background(Color.white)
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
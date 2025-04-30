import SwiftUI

struct ProfileHeaderView: View {
    var onBack: (() -> Void)?
    var onSwitchProfile: (() -> Void)?
    var onSettings: (() -> Void)?
    var body: some View {
        ZStack {
            HStack {
                Button(action: { onBack?() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                Spacer()
                Button(action: { onSwitchProfile?() }) {
                    Image(systemName: "arrow.triangle.2.circlepath") // cycle 비슷한 아이콘
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Button(action: { onSettings?() }) {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 31)
            HStack {
                Spacer()
                Text("프로필")
                    .font(Font.custom("Pretendard", size: 20).weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .allowsHitTesting(false) // 제목이 버튼 클릭을 막지 않게
        }
        .frame(height: 51)
    }
}
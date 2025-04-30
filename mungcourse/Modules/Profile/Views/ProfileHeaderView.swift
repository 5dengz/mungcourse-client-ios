import SwiftUI

struct ProfileHeaderView: View {
    var onBack: (() -> Void)?
    var onSwitchProfile: (() -> Void)?
    var onSettings: (() -> Void)?
    var body: some View {
        CommonHeaderView(leftIcon: "chevron.left", leftAction: onBack, title: "프로필") {
            HStack(spacing: 16) {
                Button(action: { onSwitchProfile?() }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Button(action: { onSettings?() }) {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
        }
        .frame(height: 51)
    }
}
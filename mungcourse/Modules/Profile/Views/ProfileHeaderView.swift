import SwiftUI

struct ProfileHeaderView: View {
    var onBack: (() -> Void)?
    var onSwitchProfile: (() -> Void)?
    var onSettings: (() -> Void)?
    var body: some View {
        HStack {
            Button(action: { onBack?() }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            Text("프로필")
                .font(.headline)
                .frame(maxWidth: .infinity)
            Button(action: { onSwitchProfile?() }) {
                Text("프로필 전환")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            Button(action: { onSettings?() }) {
                Image(systemName: "gearshape")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
        .frame(height: 51)
    }
}
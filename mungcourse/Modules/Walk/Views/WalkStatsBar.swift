import SwiftUI

struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
                
            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct WalkStatsBar: View {
    let distance: String
    let duration: String
    let calories: String

    var body: some View {
        HStack(spacing: 0) {
            StatItem(label: "거리(km)", value: distance)
            Divider()
                .frame(width: 1, height: 22)
                .background(Color(UIColor.systemGray4))
            StatItem(label: "시간", value: duration)
            Divider()
                .frame(width: 1, height: 22)
                .background(Color(UIColor.systemGray4))
            StatItem(label: "칼로리", value: calories)
        }
        .background(Color(UIColor.systemBackground))
        .padding(.vertical, 8)
    }
}

#Preview {
    WalkStatsBar(
        distance: "1.25",
        duration: "10:30",
        calories: "120"
    )
}

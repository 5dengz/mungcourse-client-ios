import SwiftUI

struct StatItem: View {
    let label: String
    let value: String
    let valueColor: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color("gray500"))
            Text(value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(valueColor)
        }
        .frame(maxWidth: .infinity)
    }
}

struct WalkStatsBar: View {
    let distance: String
    let duration: String
    let calories: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: 0) {
            StatItem(label: "거리(km)", value: distance, valueColor: Color("pointblack"))
            Divider()
                .frame(width: 1, height: 22)
                .background(Color("gray300"))
            StatItem(label: "시간", value: duration, valueColor: isActive ? Color("main") : Color("pointblack"))
            Divider()
                .frame(width: 1, height: 22)
                .background(Color("gray300"))
            StatItem(label: "칼로리", value: calories, valueColor: Color("pointblack"))
        }
        .background(Color("pointwhite"))
        .padding(.vertical, 8)
    }
}

#Preview {
    WalkStatsBar(
        distance: "1.25",
        duration: "10:30",
        calories: "120",
        isActive: true
    )
}

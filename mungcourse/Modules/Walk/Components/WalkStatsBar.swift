import SwiftUI

struct WalkStatsBar: View {
    let distance: String  // in km
    let duration: String  // formatted time
    let calories: String  // in kcal
    
    var body: some View {
        VStack(spacing: 0) {
            // Top row with labels
            HStack(spacing: 0) {
                Text("거리(km)")
                    .frame(maxWidth: .infinity)
                Divider()
                    .background(Color(UIColor.systemGray4))
                    .frame(width: 1, height: 20)
                Text("시간")
                    .frame(maxWidth: .infinity)
                Divider()
                    .background(Color(UIColor.systemGray4))
                    .frame(width: 1, height: 20)
                Text("칼로리")
                    .frame(maxWidth: .infinity)
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            .padding(.vertical, 8)
            .background(Color(UIColor.systemBackground))
            
            Divider()
                .background(Color(UIColor.systemGray4))
            
            // Bottom row with values
            HStack(spacing: 0) {
                Text(distance)
                    .frame(maxWidth: .infinity)
                Divider()
                    .background(Color(UIColor.systemGray4))
                    .frame(width: 1, height: 24)
                Text(duration)
                    .frame(maxWidth: .infinity)
                Divider()
                    .background(Color(UIColor.systemGray4))
                    .frame(width: 1, height: 24)
                Text(calories)
                    .frame(maxWidth: .infinity)
            }
            .font(.system(size: 18, weight: .semibold))
            .padding(.vertical, 10)
            .background(Color(UIColor.systemBackground))
        }
    }
}

#Preview {
    WalkStatsBar(
        distance: "1.25",
        duration: "10:30",
        calories: "120"
    )
    .previewLayout(.sizeThatFits)
}
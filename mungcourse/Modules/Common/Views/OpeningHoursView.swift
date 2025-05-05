import SwiftUI

struct OpeningHoursView: View {
    let openingHours: String // 예: "월~금 09:00~18:00"

    var body: some View {
        let (days, hours) = OpeningHoursView.splitOpeningHours(openingHours)
        HStack(spacing: 4) {
            if !days.isEmpty {
                Text(days)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.black)
            }
            if !hours.isEmpty {
                Text(hours)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("main"))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color("white"))
        )
    }
    // 요일과 시간 분리 함수 (예: "월~금 09:00~18:00" → ("월~금", "09:00~18:00"))
    static func splitOpeningHours(_ str: String) -> (String, String) {
        let parts = str.split(separator: " ", maxSplits: 1).map { String($0) }
        if parts.count == 2 {
            return (parts[0], parts[1])
        } else {
            return ("", str)
        }
    }
}

#Preview {
    VStack {
        OpeningHoursView(openingHours: "월~금 09:00~18:00")
        OpeningHoursView(openingHours: "토~일 10:00~20:00")
        OpeningHoursView(openingHours: "09:00~18:00")
    }
    .padding()
    .background(Color("gray900"))
} 
import SwiftUI

// 요일 버튼 컴포넌트
struct DayButton: View {
    let day: DayOfWeek
    let dateNumber: Int
    let isSelected: Bool
    let isToday: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 29.5)
                    .fill(isSelected ? Color(red: 0.15, green: 0.75, blue: 0) : Color(red: 0.94, green: 0.94, blue: 0.94))
                    .frame(width: 41, height: 58)
                VStack(spacing: 2) {
                    Text(day.rawValue)
                        .font(.custom("Pretendard", size: 12).weight(isToday ? .semibold : .regular))
                        .foregroundColor(isSelected ? .white : Color(red: 0.62, green: 0.62, blue: 0.62))
                    Text("\(dateNumber)")
                        .font(.custom("Pretendard", size: 14).weight(isToday ? .semibold : .regular))
                        .foregroundColor(isSelected ? .white : Color(red: 0.62, green: 0.62, blue: 0.62))
                }
            }
        }
    }
} 
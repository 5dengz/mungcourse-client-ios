import SwiftUI

// 요일/날짜 선택 컴포넌트
struct RoutineDaySelector: View {
    @Binding var selectedDay: DayOfWeek
    // 선택된 날짜 기준으로 주를 표시하기 위한 기준 날짜
    let baseDate: Date

    // 이번 주 각 요일에 해당하는 날짜 배열
    private var weekDates: [Date] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        // baseDate를 기준으로 주의 시작점 계산
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: baseDate)) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    var body: some View {
        // 요일 선택 버튼 스크롤
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 11) {
                ForEach(0..<DayOfWeek.allCases.count, id: \.self) { index in
                    let day = DayOfWeek.allCases[index]
                    let date = weekDates[index]
                    let dateNumber = Calendar.current.component(.day, from: date)
                    DayButton(
                        day: day,
                        dateNumber: dateNumber,
                        isSelected: selectedDay == day,
                        isToday: Calendar.current.isDateInToday(date)
                    ) {
                        selectedDay = day
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
    }
}
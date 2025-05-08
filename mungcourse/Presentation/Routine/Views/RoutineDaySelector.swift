import SwiftUI

// 요일/날짜 선택 컴포넌트
struct RoutineDaySelector: View {
    @Binding var selectedDay: DayOfWeek
    
    // 오늘부터 시작하는 7일의 날짜 배열
    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = Date()
        // 오늘부터 7일간의 날짜 생성
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
    }
    
    var body: some View {
        // 요일 선택 버튼
        HStack(spacing: 8) {
            ForEach(0..<7, id: \.self) { index in
                let date = weekDates[index]
                let calendar = Calendar.current
                let weekdayNum = calendar.component(.weekday, from: date)
                // weekday는 1(일요일)부터 7(토요일)까지이므로 DayOfWeek 값으로 변환
                // DayOfWeek는 0(월요일)부터 6(일요일)이므로 조정 필요
                let adjustedIndex = (weekdayNum + 5) % 7 // 일요일(1)을 6으로, 월요일(2)을 0으로 변환
                let day = DayOfWeek.allCases[adjustedIndex]
                let dateNumber = calendar.component(.day, from: date)
                DayButton(
                    day: day,
                    dateNumber: dateNumber,
                    isSelected: selectedDay == day,
                    isToday: calendar.isDateInToday(date)
                ) {
                    selectedDay = day
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
} 
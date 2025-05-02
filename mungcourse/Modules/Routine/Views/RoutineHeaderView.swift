import SwiftUI

// 헤더 뷰 컴포넌트
struct RoutineHeaderView: View {
    @Binding var selectedDay: DayOfWeek
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("루틴 설정")
                    .font(.custom("Pretendard", size: 20).weight(.semibold))
                    .foregroundColor(.black)
                Spacer()
                Image("icon_calendar")
            }
            .padding(.vertical)
            .padding(.horizontal, 20)
            
            // 요일 선택 영역 삽입
            RoutineDaySelector(selectedDay: $selectedDay)
                .padding(.top, 8)
        }
        .background(Color.white)
        .frame(maxWidth: .infinity)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 4)
    }
} 
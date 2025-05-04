import SwiftUI

// 달력 구현을 위한 Date 확장
extension Date {
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    
    func endOfMonth() -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        components.day = -1
        return calendar.date(byAdding: components, to: self.startOfMonth())!
    }
    
    func getAllDatesInMonth() -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: self)!
        let start = self.startOfMonth()
        return range.compactMap { day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: start)!
        }
    }
    
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    // yyyy년 MM월 형식
    func formatYearMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }
    
    // d 형식 (날짜만)
    func formatDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }
    
    // 요일 계산 (0: 일요일, 1: 월요일, ..., 6: 토요일)
    func weekday() -> Int {
        return Calendar.current.component(.weekday, from: self) - 1
    }
}

// 산책 기록 뷰 모델
class WalkHistoryViewModel: ObservableObject {
    @Published var selectedDate: Date
    @Published var currentMonth: Date
    
    let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    
    init() {
        self.selectedDate = Date()
        self.currentMonth = Date()
    }
    
    // 이전달로 이동
    func gotoPreviousMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    // 다음달로 이동
    func gotoNextMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    // 월의 시작 요일 계산 (0: 일요일, 1: 월요일, ..., 6: 토요일)
    func firstWeekdayOfMonth() -> Int {
        return currentMonth.startOfMonth().weekday()
    }
    
    // 현재 월의 모든 날짜 배열 가져오기
    func daysInMonth() -> [Date] {
        return currentMonth.getAllDatesInMonth()
    }
}

struct WalkHistoryView: View {
    @StateObject private var viewModel = WalkHistoryViewModel()
    @State private var navigateToDetail: Bool = false
    @State private var selectedDate: Date? = nil
    
    // 가로 간격 7.5로 설정된 그리드 아이템 정의
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 7.5), count: 7)
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // 배경색을 상단 SafeArea까지 확장
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 자체 구현 헤더 (그림자 없음)
                    ZStack {
                        Text("산책 기록")
                            .font(.custom("Pretendard-SemiBold", size: 18))
                            .foregroundColor(Color("gray900"))
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 85)
                    
                    // 헤더와 콘텐츠 사이에 그림자만 적용
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 1)
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                    
                    // 년월 선택 및 좌우 이동 버튼
                    HStack {
                        Button(action: {
                            viewModel.gotoPreviousMonth()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color("gray400"))
                                .font(.system(size: 20)) // 화살표 크기 증가
                        }
                        
                        Spacer()
                        
                        Text(viewModel.currentMonth.formatYearMonth())
                            .font(.custom("Pretendard-SemiBold", size: 16))
                            .foregroundColor(Color("gray900"))
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.gotoNextMonth()
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color("gray400"))
                                .font(.system(size: 20)) // 화살표 크기 증가
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    
                    // 요일 헤더
                    HStack(spacing: 0) {
                        ForEach(viewModel.weekdays, id: \.self) { weekday in
                            Text(weekday)
                                .font(.custom("Pretendard-Regular", size: 14))
                                .foregroundColor(Color("gray400"))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    
                    // 날짜 그리드 - 가로 간격 7.5, 세로 간격 11.5로 설정
                    LazyVGrid(columns: columns, spacing: 11.5) {
                        // 첫번째 요일에 맞추어 빈 셀 추가
                        ForEach(0..<viewModel.firstWeekdayOfMonth(), id: \.self) { _ in
                            Text("")
                                .frame(height: 40)
                        }
                        
                        // 날짜들 표시
                        ForEach(viewModel.daysInMonth(), id: \.self) { date in
                            Button(action: {
                                selectedDate = date
                                navigateToDetail = true
                            }) {
                                Text(date.formatDay())
                                    .font(.custom("Pretendard-Regular", size: 14))
                                    .foregroundColor(date.isToday() ? .white : Color("gray400"))
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(date.isToday() ? Color("main") : Color("gray300"))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    
                    Spacer()
                }
            }
            .toolbar(.hidden) // 기본 내비게이션 바를 숨김
            .navigationDestination(isPresented: $navigateToDetail) {
                if let date = selectedDate {
                    WalkHistoryDetailView(date: date)
                }
            }
        }
    }
}

#Preview {
    WalkHistoryView()
}

import SwiftUI

struct WalkHistoryView: View {
    @StateObject private var viewModel = WalkHistoryViewModel()
    @State private var navigateToDetail = false

    // 가로 간격 7.5로 설정된 그리드 아이템 정의
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 7.5), count: 7)
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // 배경색을 상단 SafeArea까지 확장
                Color("pointwhite")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 자체 구현 헤더 (흰색 배경과 하단 그림자 적용)
                    ZStack {
                        Text("산책 기록")
                            .font(.custom("Pretendard-SemiBold", size: 20))
                            .foregroundColor(Color("gray900"))
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 85)
                    .background(Color("pointwhite")) // 명시적으로 흰색 배경 지정
                    .shadow(color: Color("pointblack").opacity(0.1), radius: 5, x: 0, y: 2) // 그림자 적용
                    
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
                            .font(.custom("Pretendard-SemiBold", size: 18))
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
                    .padding(.horizontal, 28)
                    .padding(.vertical, 32)
                    
                    // 요일 헤더
                    HStack(spacing: 0) {
                        ForEach(viewModel.weekdays, id: \.self) { weekday in
                            Text(weekday)
                                .font(.custom("Pretendard-Regular", size: 14))
                                .foregroundColor(Color("gray400"))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    
                    // 로딩 중 표시
                    if viewModel.isLoadingDates {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.vertical, 100)
                    } else {
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
                                    viewModel.loadWalkRecords(for: date)
                                    navigateToDetail = true
                                }) {
                                    Text(date.formatDay())
    .font(.custom("Pretendard-Regular", size: 16))
    .foregroundColor(getDateTextColor(date))
    .frame(width: 40, height: 40)
    .background(
        Circle()
            .fill(getDateBackgroundColor(date))
    )
    .overlay(
        Circle()
            .stroke(date.isToday() ? Color("main") : (viewModel.hasWalkRecord(for: date) ? Color("main") : Color.clear), lineWidth: date.isToday() ? 2 : (viewModel.hasWalkRecord(for: date) ? 2 : 0))
    )
                                }
                                .disabled(date > Date()) // 미래 날짜는 비활성화만, 숫자는 항상 보임
                            }
                        }
                        .padding(.horizontal, 28)
                    }
                    
                    // 에러 메시지 표시 (콘솔 로그만, 화면에는 표시하지 않음)
                    // if viewModel.dateError != nil {
                    //     Text("데이터를 불러오는 중 오류가 발생했습니다.")
                    //         .font(.custom("Pretendard-Regular", size: 14))
                    //         .foregroundColor(.red)
                    //         .padding()
                    // }
                    
                    Spacer()
                }
            }
            .toolbar(.hidden) // 기본 내비게이션 바를 숨김
            .navigationDestination(isPresented: $navigateToDetail) {
                WalkHistoryDetailView(viewModel: viewModel)
            }
            .onAppear {
                // 화면이 나타날 때마다 현재 월의 데이터 새로고침
                viewModel.loadWalkDatesForCurrentMonth()
            }
        }
    }
    
    // 날짜 텍스트 색상 결정
    private func getDateTextColor(_ date: Date) -> Color {
    if viewModel.hasWalkRecord(for: date) {
        return Color("pointwhite")
    } else if date.isToday() {
        return Color("main")
    } else {
        return Color("gray400")
    }
}
    
    // 날짜 배경 색상 결정
    private func getDateBackgroundColor(_ date: Date) -> Color {
    if viewModel.hasWalkRecord(for: date) {
        return Color("main")
    } else if date.isToday() {
        return Color("main")
    } else {
        return Color("gray200")
    }
}
}

#Preview {
    WalkHistoryView()
}

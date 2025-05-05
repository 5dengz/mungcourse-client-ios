import SwiftUI
import Charts // Charts 프레임워크 추가

// 산책 데이터 모델 정의
struct WalkData: Identifiable, Equatable {
    let id = UUID()
    let day: String
    let distance: Double
    
    // Equatable 프로토콜 구현 - UUID를 제외하고 day와 distance만 비교
    static func == (lhs: WalkData, rhs: WalkData) -> Bool {
        lhs.day == rhs.day && lhs.distance == rhs.distance
    }
}

// 주간 산책 차트 뷰 - 별도 컴포넌트로 분리
struct WeeklyWalkChartView: View {
    let walkData: [WalkData]
    
    var body: some View {
        Chart {
            ForEach(walkData) { data in
                makeBarMark(for: data)
            }
        }
        .chartYAxis(content: configureYAxis)
        .chartXAxis(content: configureXAxis)
        .frame(height: 250)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: walkData)
    }
    
    // BarMark 생성 및 스타일링을 위한 메서드
    private func makeBarMark(for data: WalkData) -> some ChartContent {
        BarMark(
            x: .value("요일", data.day),
            y: .value("거리(km)", data.distance)
        )
        .foregroundStyle(
            LinearGradient(
                colors: [Color("main").opacity(0.8), Color("main")],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(8)
        .annotation(position: .top) {
            Text("\(String(format: "%.1f", data.distance))")
                .font(.custom("Pretendard-Regular", size: 12))
                .foregroundColor(Color("gray600"))
                .padding(.top, 4)
        }
    }
    
    // Y축 설정을 위한 메서드
    private func configureYAxis() -> some AxisContent {
        AxisMarks(position: .leading) { value in
            AxisGridLine()
            if let distance = value.as(Double.self) {
                AxisValueLabel {
                    Text("\(String(format: "%.1f", distance)) km")
                        .font(.custom("Pretendard-Regular", size: 10))
                        .foregroundColor(Color("gray400"))
                }
            }
        }
    }
    
    // X축 설정을 위한 메서드
    private func configureXAxis() -> some AxisContent {
        AxisMarks { value in
            AxisValueLabel {
                if let day = value.as(String.self) {
                    Text(day)
                        .font(.custom("Pretendard-Regular", size: 12))
                        .foregroundColor(Color("gray400"))
                }
            }
        }
    }
}

struct WalkHistoryDetailView: View {
    let date: Date
    @Environment(\.dismiss) private var dismiss
    
    // 주간 산책 기록 샘플 데이터 (실제로는 서비스에서 데이터를 가져와야 함)
    private let weeklyWalkData: [WalkData] = [
        WalkData(day: "월", distance: 1.2),
        WalkData(day: "화", distance: 2.5),
        WalkData(day: "수", distance: 1.8),
        WalkData(day: "목", distance: 3.4),
        WalkData(day: "금", distance: 2.1),
        WalkData(day: "토", distance: 4.5),
        WalkData(day: "일", distance: 3.2)
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            // 배경색을 상단 SafeArea까지 확장
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 자체 구현 헤더 (흰색 배경과 하단 그림자 적용)
                ZStack {
                    Text("\(formatDate(date: date)) 산책 기록")
                        .font(.custom("Pretendard-SemiBold", size: 20))
                        .foregroundColor(Color("gray900"))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                    
                    // 뒤로 가기 버튼
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20))
                                .foregroundColor(Color("gray900"))
                        }
                        Spacer()
                    }
                    .padding(.leading, 20)
                }
                .frame(height: 85)
                .background(Color.white) // 명시적으로 흰색 배경 지정
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // 그림자 적용
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("선택하신 날짜의 산책 기록입니다.")
                            .font(.custom("Pretendard-Regular", size: 16))
                            .padding(.top, 30)
                        
                        // 산책 정보 카드 (거리, 시간, 칼로리)
                        HStack(spacing: 12) {
                            InfoCard(title: "산책 거리", value: "2.5 km", iconName: "location")
                            InfoCard(title: "산책 시간", value: "45 분", iconName: "clock")
                            InfoCard(title: "소모 칼로리", value: "150 kcal", iconName: "flame.fill")
                        }
                        .padding(.top, 10)
                        
                        // 주간 산책 거리 차트 섹션 - 별도 뷰로 분리
                        VStack(alignment: .leading, spacing: 15) {
                            Text("주간 산책 기록")
                                .font(.custom("Pretendard-SemiBold", size: 18))
                                .foregroundColor(Color("gray900"))
                            
                            // 분리된 차트 컴포넌트 사용
                            WeeklyWalkChartView(walkData: weeklyWalkData)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                        )
                        .padding(.top, 25)
                        
                        // 산책 경로 지도 섹션
                        VStack(alignment: .leading, spacing: 15) {
                            Text("산책 경로")
                                .font(.custom("Pretendard-SemiBold", size: 18))
                                .foregroundColor(Color("gray900"))
                            
                            // 산책 경로 지도가 표시될 영역 (임시)
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("gray300"))
                                .frame(height: 250)
                                .overlay(
                                    Text("산책 경로 지도")
                                        .foregroundColor(Color("gray600"))
                                )
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                        )
                        .padding(.top, 16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // 날짜 포맷팅 함수 (yyyy년 MM월 dd일)
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

// 정보 카드 컴포넌트
struct InfoCard: View {
    let title: String
    let value: String
    let iconName: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundColor(Color("main"))
            
            Text(value)
                .font(.custom("Pretendard-SemiBold", size: 16))
                .foregroundColor(Color("gray900"))
            
            Text(title)
                .font(.custom("Pretendard-Regular", size: 12))
                .foregroundColor(Color("gray400"))
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
    }
}

#Preview {
    NavigationStack {
        WalkHistoryDetailView(date: Date())
    }
}
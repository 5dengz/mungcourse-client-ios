import SwiftUI
import Charts
import NMapsMap

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

// Identifiable을 준수하는 Int 래퍼 구조체
struct IdentifiableInt: Identifiable {
    let id: Int
    
    init(_ value: Int) {
        self.id = value
    }
}

struct WalkHistoryDetailView: View {
    @ObservedObject var viewModel: WalkHistoryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedWalkId: IdentifiableInt? = nil

    // 하루 총합 산책 통계 계산
    private var totalDistance: String {
        let sum = viewModel.walkRecords.reduce(0.0) { $0 + $1.distanceKm }
        return String(format: "%.2f", sum)
    }
    private var totalDuration: String {
        let totalSec = viewModel.walkRecords.reduce(0) { $0 + $1.durationSec }
        let h = totalSec / 3600
        let m = (totalSec % 3600) / 60
        return String(format: "%02d:%02d", h, m)
    }
    private var totalCalories: String {
        let sum = viewModel.walkRecords.reduce(0) { $0 + $1.calories }
        return String(sum)
    }
    // 시간대별 산책 분 계산 (0~23시)
    private var hourlyMinutes: [Int] {
        var arr = Array(repeating: 0, count: 24)
        for record in viewModel.walkRecords {
            if let date = ISO8601DateFormatter().date(from: record.startedAt),
               let hour = Calendar.current.dateComponents([.hour], from: date).hour {
                arr[hour] += record.durationSec / 60
            }
        }
        return arr
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // 배경색을 상단 SafeArea까지 확장
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 자체 구현 헤더 (흰색 배경과 하단 그림자 적용)
                ZStack {
                    Text("\(formatDate(date: viewModel.selectedDate))")
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
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                ScrollView {
                    if viewModel.isLoadingRecords {
                        // 로딩 중
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                    } else if viewModel.walkRecords.isEmpty {
                        // 데이터 없음
                        VStack(spacing: 20) {
                            Image(systemName: "pawprint")
                                .font(.system(size: 50))
                                .foregroundColor(Color("gray300"))
                                .padding(.top, 50)
                            Text("산책 기록이 없습니다")
                                .font(.custom("Pretendard-Regular", size: 18))
                                .foregroundColor(Color("gray500"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    } else {
                        VStack(alignment: .leading, spacing: 32) {
                            // 하루 총 산책 섹션
                            Text("하루 총 산책")
                                .font(.custom("Pretendard-SemiBold", size: 18))
                                .foregroundColor(Color("gray900"))
                                .padding(.top, 8)
                                .padding(.leading, 2)

                            // 하루 총합 통계 바
                            WalkStatsBar(
                                distance: totalDistance,
                                duration: totalDuration,
                                calories: totalCalories,
                                isActive: true
                            )

                            // 시간대별 산책 분 그래프
                            WalkTimeChartView(hourlyMinutes: hourlyMinutes)
                                .frame(height: 180)
                                .padding(.top, 8)

                            // 산책 요약 섹션
                            Text("산책 요약")
                                .font(.custom("Pretendard-SemiBold", size: 18))
                                .foregroundColor(Color("gray900"))
                                .padding(.top, 16)
                                .padding(.leading, 2)

                            VStack(spacing: 20) {
                                ForEach(viewModel.walkRecords) { record in
                                    WalkRouteSummaryView(
                                        coordinates: record.gpsData.map { NMGLatLng(lat: $0.lat, lng: $0.lng) },
                                        distance: String(format: "%.2f", record.distanceKm),
                                        duration: record.formattedDuration,
                                        calories: String(record.calories),
                                        isLoading: false,
                                        errorMessage: nil,
                                        emptyMessage: "저장된 경로 정보가 없습니다",
                                        boundingBox: nil,
                                        mapHeight: 180
                                    )
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white)
                                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                                    )
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedWalkId) { walkIdWrapper in
            if let detail = viewModel.selectedWalkDetail {
                WalkDetailSheet(walkDetail: detail, dismiss: {
                    selectedWalkId = nil
                })
            } else {
                ProgressView()
                    .onDisappear {
                        selectedWalkId = nil
                    }
            }
        }
    }
    
    private var selectedWalkIdBinding: Binding<IdentifiableInt?> {
        Binding<IdentifiableInt?>(
            get: { self._selectedWalkId.wrappedValue },
            set: { self._selectedWalkId.wrappedValue = $0 }
        )
    }
    
    // 날짜 포맷팅 함수 (yyyy년 MM월 dd일)
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

// 산책 기록 카드 컴포넌트
struct WalkRecordCard: View {
    let record: WalkRecord
    
    var body: some View {
        HStack(spacing: 16) {
            // 시간 표시
            VStack(alignment: .leading, spacing: 4) {
                Text(record.formattedStartTime)
                    .font(.custom("Pretendard-SemiBold", size: 18))
                    .foregroundColor(Color("gray900"))
                
                Text("\(record.formattedDuration) 소요")
                    .font(.custom("Pretendard-Regular", size: 14))
                    .foregroundColor(Color("gray500"))
            }
            
            Spacer()
            
            // 거리 표시
            VStack(alignment: .trailing, spacing: 4) {
                Text(record.formattedDistance)
                    .font(.custom("Pretendard-SemiBold", size: 18))
                    .foregroundColor(Color("main"))
                
                Text("\(record.calories) kcal")
                    .font(.custom("Pretendard-Regular", size: 14))
                    .foregroundColor(Color("gray500"))
            }
            
            // 화살표 아이콘
            Image(systemName: "chevron.right")
                .foregroundColor(Color("gray400"))
                .font(.system(size: 16))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
    }
}

// 산책 상세 정보 시트
struct WalkDetailSheet: View {
    let walkDetail: WalkDetail
    let dismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            ZStack {
                Text("산책 상세 정보")
                    .font(.custom("Pretendard-SemiBold", size: 18))
                    .foregroundColor(Color("gray900"))
                
                HStack {
                    Spacer()
                    Button(action: dismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundColor(Color("gray700"))
                    }
                }
                .padding(.trailing, 16)
            }
            .padding(.top, 24)
            .padding(.bottom, 16)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 산책 정보 카드 (거리, 시간, 칼로리)
                    HStack(spacing: 12) {
                        InfoCard(title: "산책 거리", value: walkDetail.formattedDistance, iconName: "location")
                        InfoCard(title: "산책 시간", value: walkDetail.formattedDuration, iconName: "clock")
                        InfoCard(title: "소모 칼로리", value: "\(walkDetail.calories) kcal", iconName: "flame.fill")
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    
                    // 산책 경로 지도+통계 통합 뷰
                    WalkRouteSummaryView(
                        coordinates: walkDetail.gpsData.map { NMGLatLng(lat: $0.lat, lng: $0.lng) },
                        distance: walkDetail.formattedDistance,
                        duration: walkDetail.formattedDuration,
                        calories: "\(walkDetail.calories)",
                        isLoading: false,
                        errorMessage: nil,
                        emptyMessage: "저장된 경로 정보가 없습니다",
                        boundingBox: nil,
                        mapHeight: 200
                    )
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .padding(.bottom, 30)
            }
        }
        .presentationDetents([.large, .medium])
        .presentationDragIndicator(.visible)
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

// 시간대별 산책 분 그래프 뷰
struct WalkTimeChartView: View {
    let hourlyMinutes: [Int] // 0~23시, 각 시간대별 산책 분
    var body: some View {
        Chart {
            ForEach(0..<hourlyMinutes.count, id: \.self) { hour in
                BarMark(
                    x: .value("시간", hour),
                    y: .value("산책 분", hourlyMinutes[hour])
                )
                .foregroundStyle(Color("main"))
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: 2)) { value in
                AxisValueLabel {
                    if let hour = value.as(Int.self) {
                        Text(String(format: "%02d시", hour))
                            .font(.system(size: 10))
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks() { value in
                AxisValueLabel()
            }
        }
    }
}

#Preview {
    NavigationStack {
        WalkHistoryDetailView(viewModel: WalkHistoryViewModel())
    }
}
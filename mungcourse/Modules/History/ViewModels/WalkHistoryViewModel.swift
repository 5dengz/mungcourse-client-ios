import Foundation
import Combine
import SwiftUI

class WalkHistoryViewModel: ObservableObject {
    // 달력 관련 데이터
    @Published var selectedDate: Date
    @Published var currentMonth: Date
    @Published var walkDates: [String] = [] // YYYY-MM-DD 형식의 산책 날짜 목록
    @Published var isLoadingDates: Bool = false
    @Published var dateError: Error? = nil
    
    // 선택한 날짜의 산책 기록
    @Published var walkRecords: [WalkRecord] = []
    @Published var isLoadingRecords: Bool = false
    @Published var recordsError: Error? = nil
    
    // 선택한 산책의 상세 정보
    @Published var selectedWalkDetail: WalkDetail? = nil
    @Published var isLoadingDetail: Bool = false
    @Published var detailError: Error? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    
    init() {
        self.selectedDate = Date()
        self.currentMonth = Date()
        
        // 초기 데이터 로드
        loadWalkDatesForCurrentMonth()
    }
    
    // MARK: - 달력 관련 메소드
    
    // 이전달로 이동
    func gotoPreviousMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
            loadWalkDatesForCurrentMonth()
        }
    }
    
    // 다음달로 이동
    func gotoNextMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
            loadWalkDatesForCurrentMonth()
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
    
    // 날짜가 산책 기록이 있는지 확인
    func hasWalkRecord(for date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        return walkDates.contains(dateString)
    }
    
    // MARK: - API 호출 메소드
    
    // 현재 월에 대한 산책 날짜 데이터 로드
    func loadWalkDatesForCurrentMonth() {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: currentMonth)
        let month = calendar.component(.month, from: currentMonth)
        
        isLoadingDates = true
        dateError = nil
        
        WalkService.shared.fetchWalkDates(year: year, month: month)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoadingDates = false
                    if case .failure(let error) = completion {
                        self?.dateError = error
                        print("산책 날짜 로드 실패: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] walkDateResponses in
                    self?.walkDates = walkDateResponses.map { $0.date }
                    print("산책 날짜 로드 완료: \(walkDateResponses.count)개")
                }
            )
            .store(in: &cancellables)
    }
    
    // 선택한 날짜의 산책 기록 로드
    func loadWalkRecords(for date: Date) {
        isLoadingRecords = true
        recordsError = nil
        selectedDate = date
        
        WalkService.shared.fetchWalkRecords(date: date)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoadingRecords = false
                    if case .failure(let error) = completion {
                        self?.recordsError = error
                        print("산책 기록 로드 실패: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] records in
                    self?.walkRecords = records
                    print("산책 기록 로드 완료: \(records.count)개")
                }
            )
            .store(in: &cancellables)
    }
    
    // 산책 상세 정보 로드
    func loadWalkDetail(walkId: Int) {
        isLoadingDetail = true
        detailError = nil
        
        WalkService.shared.fetchWalkDetail(walkId: walkId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoadingDetail = false
                    if case .failure(let error) = completion {
                        self?.detailError = error
                        print("산책 상세 정보 로드 실패: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] detail in
                    self?.selectedWalkDetail = detail
                    print("산책 상세 정보 로드 완료: ID \(detail.id)")
                }
            )
            .store(in: &cancellables)
    }
}

// Date 확장은 Modules/Common/Extensions/Date+Calendar.swift로 이동했습니다.
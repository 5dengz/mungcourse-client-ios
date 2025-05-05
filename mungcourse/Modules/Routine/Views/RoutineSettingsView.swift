import SwiftUI
import Combine

// 루틴 모델
struct Routine: Identifiable {
    let routineId: Int
    let routineCheckId: Int
    let id: UUID
    var title: String
    var time: String
    var isDone: Bool
    var days: Set<DayOfWeek>
    
    init(routineId: Int, routineCheckId: Int, id: UUID = UUID(), title: String, time: String, isDone: Bool = false, days: Set<DayOfWeek>) {
        self.routineId = routineId
        self.routineCheckId = routineCheckId
        self.id = id
        self.title = title
        self.time = time
        self.isDone = isDone
        self.days = days
    }
}

// 루틴 뷰모델
class RoutineViewModel: ObservableObject {
    @Published var routines: [Routine] = []
    @Published var selectedDay: DayOfWeek = .today
    @Published var showAddRoutine: Bool = false
    @Published var editingRoutine: Routine? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchRoutines(for: selectedDay)
        $selectedDay
            .sink { [weak self] day in
                self?.fetchRoutines(for: day)
            }
            .store(in: &cancellables)
    }
    
    /// 특정 요일의 루틴을 API로 가져옵니다.
    func fetchRoutines(for day: DayOfWeek) {
        let dateStr = dateString(for: day)
        RoutineService.shared.fetchRoutines(date: dateStr)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching routines: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] dataList in
                self?.routines = dataList.map {
                    Routine(routineId: $0.routineId, routineCheckId: $0.routineCheckId, title: $0.name, time: $0.alarmTime, isDone: $0.isCompleted, days: [day])
                }
            })
            .store(in: &cancellables)
    }
    
    /// DayOfWeek를 기반으로 yyyy-MM-dd 형식의 날짜 문자열을 생성합니다.
    private func dateString(for day: DayOfWeek) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else {
            return ""
        }
        let dates = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
        if let index = DayOfWeek.allCases.firstIndex(of: day), index < dates.count {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: dates[index])
        }
        return ""
    }
    
    // 선택된 요일에 해당하는 루틴들만 필터링 (fetch에서 이미 필터링됨)
    func filteredRoutines() -> [Routine] {
        routines.filter { $0.days.contains(selectedDay) }
    }
    
    // 루틴 완료 상태 토글 (API 호출)
    func toggleRoutineCompletion(routine: Routine) {
        RoutineService.shared.toggleRoutineCheck(routineCheckId: routine.routineCheckId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error toggling routine check: \(error)")
                }
            }, receiveValue: { [weak self] in
                self?.fetchRoutines(for: self?.selectedDay ?? .monday)
            })
            .store(in: &cancellables)
    }
    
    // 루틴 삭제 (API 호출)
    func deleteRoutine(_ routine: Routine) {
        RoutineService.shared.deleteRoutine(routineId: routine.routineId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error deleting routine: \(error)")
                }
            }, receiveValue: { [weak self] in
                self?.fetchRoutines(for: self?.selectedDay ?? .monday)
            })
            .store(in: &cancellables)
    }
    
    // 새 루틴 등록 (API 호출)
    func addRoutine(title: String, time: String, days: Set<DayOfWeek>) {
        let repeatDays = days.map { $0.apiValue }
        let request = CreateRoutineRequest(name: title, alarmTime: time, repeatDays: repeatDays, isAlarmActive: true)
        RoutineService.shared.createRoutine(requestBody: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error creating routine: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] _ in
                // 등록 후 현재 선택된 요일의 루틴 목록 리프레시
                self?.fetchRoutines(for: self?.selectedDay ?? .monday)
            })
            .store(in: &cancellables)
    }
    
    // 오늘 날짜 포맷
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: Date())
    }
}

struct RoutineSettingsView: View {
    @StateObject private var viewModel = RoutineViewModel()
    @State private var showDatePicker = false
    @State private var selectedDate = Date()
    @State private var showEditRoutine = false
    
    var body: some View {
        let routines = viewModel.filteredRoutines()
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 공통 헤더 (요일 선택 포함)
                CommonHeaderView(leftIcon: nil, title: "루틴 설정") {
                    Image("icon_calendar")
                        .onTapGesture {
                            showDatePicker = true
                        }
                }
                .padding(.top, 16)
                
                RoutineDaySelector(selectedDay: $viewModel.selectedDay)
                    .padding(.top, 8)
                
                // 루틴 리스트
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if routines.isEmpty {
                            EmptyRoutineView()
                        } else {
                            ForEach(routines.indices, id: \.self) { index in
                                let routine = routines[index]
                                RoutineListItem(
                                    routine: routine,
                                    onToggle: { viewModel.toggleRoutineCompletion(routine: routine) },
                                    onEdit: {
                                        viewModel.editingRoutine = routine
                                    },
                                    onDelete: {
                                        viewModel.deleteRoutine(routine)
                                    }
                                )
                                if index < routines.count - 1 {
                                    Divider()
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)

                Spacer()
            }
            
            // 루틴 추가 버튼 (플로팅 버튼)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    RoutineAddButton(action: {
                        viewModel.showAddRoutine = true
                    })
                    Spacer()
                }
                .padding(.bottom, 90)
            }
        }
        .sheet(isPresented: $viewModel.showAddRoutine) {
            AddRoutineView()
        }
        .sheet(item: $viewModel.editingRoutine) { routine in
            EditRoutineView(routine: routine) {
                viewModel.fetchRoutines(for: viewModel.selectedDay)
            }
        }
        .sheet(isPresented: $showDatePicker) {
            CommonDatePickerSheet(selection: $selectedDate) {
                showDatePicker = false
            } onDismiss: {
                showDatePicker = false
            }
        }
    }
}

#Preview {
    RoutineSettingsView()
}

import Foundation
import Combine

// ViewModel for RoutineSettingsView
class RoutineViewModel: ObservableObject {
    @Published var routines: [Routine] = []
    @Published var selectedDay: DayOfWeek = .today
    @Published var showAddRoutine: Bool = false
    @Published var editingRoutine: Routine? = nil

    private var cancellables = Set<AnyCancellable>()
    
    // 중복 토글 방지를 위한 처리 중인 루틴 ID 추적
    private var togglingRoutineIds = Set<Int>()

    init() {
        fetchRoutines(for: selectedDay)
        $selectedDay
            .sink { [weak self] day in
                self?.fetchRoutines(for: day)
            }
            .store(in: &cancellables)
    }

    func fetchRoutines(for day: DayOfWeek) {
        let dateStr = dateString(for: day)
        print("[RoutineViewModel] Fetching routines for date: \(dateStr)")
        
        RoutineService.shared.fetchRoutines(date: dateStr)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching routines: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] dataList in
                print("[RoutineViewModel] Received \(dataList.count) routines from server")
                dataList.forEach { data in
                    print("  - Routine: \(data.name), routineId: \(data.routineId), routineCheckId: \(data.routineCheckId), isCompleted: \(data.isCompleted)")
                }
                
                self?.routines = dataList.map {
                    Routine(routineId: $0.routineId,
                            routineCheckId: $0.routineCheckId,
                            title: $0.name,
                            time: $0.alarmTime,
                            isDone: $0.isCompleted,
                            days: [day])
                }
            })
            .store(in: &cancellables)
    }

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

    func toggleRoutineCompletion(routine: Routine) {
        // 이미 처리 중인 루틴인지 확인
        guard !togglingRoutineIds.contains(routine.routineCheckId) else {
            print("[RoutineViewModel] Toggle already in progress for routineCheckId: \(routine.routineCheckId)")
            return
        }
        
        print("[RoutineViewModel] Toggling routine: \(routine.title), routineCheckId: \(routine.routineCheckId), current state: \(routine.isDone)")
        
        // 처리 중으로 표시
        togglingRoutineIds.insert(routine.routineCheckId)
        
        // 낙관적 업데이트 제거 - 서버 응답 후 UI 업데이트
        // 대신 로딩 상태 표시 가능 (선택사항)
        
        RoutineService.shared.toggleRoutineCheck(routineCheckId: routine.routineCheckId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                // 처리 완료 후 제거
                self?.togglingRoutineIds.remove(routine.routineCheckId)
                
                if case .failure(let error) = completion {
                    print("[RoutineViewModel] Toggle failed: \(error.localizedDescription)")
                    // 실패시 에러 상태 표시 (원상복구 불필요)
                }
            }, receiveValue: { [weak self] toggleResponse in
                print("[RoutineViewModel] Toggle success from server: isCompleted=\(toggleResponse.isCompleted)")
                // 서버 응답으로 UI 상태 업데이트
                if let index = self?.routines.firstIndex(where: { $0.routineCheckId == routine.routineCheckId }) {
                    self?.routines[index].isDone = toggleResponse.isCompleted
                }
                
                // 재검증 로직 제거 (더 이상 필요 없음)
                // DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                //     self?.verifyRoutineState(routine: routine, expectedState: toggleResponse.isCompleted)
                // }
            })
            .store(in: &cancellables)
    }

    func deleteRoutine(_ routine: Routine) {
        RoutineService.shared.deleteRoutine(routineId: routine.routineId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to delete routine:", error)
                }
            }, receiveValue: { [weak self] _ in
                self?.fetchRoutines(for: self?.selectedDay ?? .today)
            })
            .store(in: &cancellables)
    }
}

import Foundation
import Combine

// ViewModel for RoutineSettingsView
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
        if let index = routines.firstIndex(where: { $0.id == routine.id }) {
            routines[index].isDone.toggle()
        }
        RoutineService.shared.toggleRoutineCheck(routineCheckId: routine.routineCheckId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error toggling routine check: \(error)")
                    if let index = self.routines.firstIndex(where: { $0.id == routine.id }) {
                        self.routines[index].isDone.toggle()
                    }
                }
            }, receiveValue: { _ in })
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

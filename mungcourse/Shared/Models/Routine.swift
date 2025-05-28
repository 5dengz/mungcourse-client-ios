import Foundation

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

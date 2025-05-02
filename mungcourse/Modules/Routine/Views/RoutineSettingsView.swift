import SwiftUI

// 루틴 모델
struct Routine: Identifiable {
    let id: UUID
    var title: String
    var time: String
    var isDone: Bool
    var days: Set<DayOfWeek>
    
    init(id: UUID = UUID(), title: String, time: String, isDone: Bool = false, days: Set<DayOfWeek>) {
        self.id = id
        self.title = title
        self.time = time
        self.isDone = isDone
        self.days = days
    }
}

// 요일 열거형
enum DayOfWeek: String, CaseIterable, Identifiable {
    case monday = "월"
    case tuesday = "화"
    case wednesday = "수"
    case thursday = "목"
    case friday = "금"
    case saturday = "토"
    case sunday = "일"
    
    var id: String { self.rawValue }
}

// 루틴 뷰모델
class RoutineViewModel: ObservableObject {
    @Published var routines: [Routine] = []
    @Published var selectedDay: DayOfWeek = .monday
    @Published var showAddRoutine: Bool = false
    @Published var newRoutineTitle: String = ""
    @Published var newRoutineTime: String = "알림 없음"
    
    init() {
        loadSampleData()
    }
    
    // 샘플 데이터 로드 (실제로는 데이터베이스나 UserDefaults에서 로드할 수 있음)
    private func loadSampleData() {
        routines = [
            Routine(title: "아침 산책", time: "오전 8시 30분", isDone: true, days: [.monday, .tuesday, .wednesday, .thursday, .friday]),
            Routine(title: "점심 사료주기", time: "알림 없음", isDone: false, days: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]),
            Routine(title: "저녁 산책", time: "오후 8시", isDone: false, days: [.monday, .tuesday, .wednesday, .thursday, .friday])
        ]
    }
    
    // 선택된 요일에 해당하는 루틴들만 필터링
    func filteredRoutines() -> [Routine] {
        return routines.filter { $0.days.contains(selectedDay) }
    }
    
    // 루틴 완료 상태 토글
    func toggleRoutineCompletion(routine: Routine) {
        if let index = routines.firstIndex(where: { $0.id == routine.id }) {
            routines[index].isDone.toggle()
        }
    }
    
    // 새 루틴 추가
    func addRoutine(title: String, time: String, days: Set<DayOfWeek>) {
        let newRoutine = Routine(title: title, time: time, days: days)
        routines.append(newRoutine)
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
    
    var body: some View {
        let routines = viewModel.filteredRoutines()
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 헤더 (요일 선택 포함)
                RoutineHeaderView(selectedDay: $viewModel.selectedDay)
                    .padding(.top, 16)
                
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
                                    onToggle: {
                                        viewModel.toggleRoutineCompletion(routine: routine)
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
            AddRoutineView(viewModel: viewModel)
        }
    }
}

#Preview {
    RoutineSettingsView()
}

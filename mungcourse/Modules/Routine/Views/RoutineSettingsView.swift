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
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 상단 상태바
                StatusBarView()
                    .padding(.top, 8)
                
                // 요일/날짜 선택 영역
                RoutineDaySelector(selectedDay: $viewModel.selectedDay, todayDate: viewModel.formattedDate())
                    .padding(.top, 16)
                
                // 루틴 리스트
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        if viewModel.filteredRoutines().isEmpty {
                            EmptyRoutineView()
                        } else {
                            ForEach(viewModel.filteredRoutines()) { routine in
                                RoutineListItem(
                                    routine: routine,
                                    onToggle: {
                                        viewModel.toggleRoutineCompletion(routine: routine)
                                    }
                                )
                            }
                        }
                    }
                    .padding()
                    .padding(.vertical, 20)
                }
                .frame(maxWidth: .infinity)
                
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
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .sheet(isPresented: $viewModel.showAddRoutine) {
            AddRoutineView(viewModel: viewModel)
        }
    }
}

// 상단 상태바 컴포넌트
struct StatusBarView: View {
    var body: some View {
        HStack {
            Text(formattedTime())
                .font(.system(size: 17, weight: .medium))
            Spacer()
            HStack(spacing: 5) {
                Image(systemName: "wifi")
                Image(systemName: "battery.100")
            }
        }
        .padding(.horizontal)
        .frame(height: 43)
    }
    
    private func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
}

// 루틴 추가 버튼 컴포넌트
struct RoutineAddButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 24.5)
                    .fill(Color(red: 0.15, green: 0.75, blue: 0))
                    .frame(width: 111, height: 41)
                    .shadow(color: Color.black.opacity(0.15), radius: 16, y: 4)
                HStack(spacing: 5) {
                    Text("+")
                        .font(.custom("Pretendard", size: 18).weight(.bold))
                    Text("루틴 추가")
                        .font(.custom("Pretendard", size: 15).weight(.semibold))
                }
                .foregroundColor(.white)
            }
        }
    }
}

// 루틴 리스트 아이템 컴포넌트
struct RoutineListItem: View {
    let routine: Routine
    var onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                ZStack {
                    Ellipse()
                        .stroke(Color(red: 0.15, green: 0.75, blue: 0), lineWidth: 0.5)
                        .background(routine.isDone ? Ellipse().fill(Color(red: 0.15, green: 0.75, blue: 0)) : Ellipse().fill(Color.clear))
                        .frame(width: 22, height: 22)
                    
                    if routine.isDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(routine.title)
                    .font(.custom("Pretendard", size: 17).weight(.semibold))
                    .foregroundColor(routine.isDone ? Color(red: 0.62, green: 0.62, blue: 0.62) : .black)
                    .strikethrough(routine.isDone)
                Text(routine.time)
                    .font(.custom("Pretendard", size: 14))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
            }
            Spacer()
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
        .contextMenu {
            Button {
                // 편집 기능 (추후 구현)
            } label: {
                Label("편집", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                // 삭제 기능 (추후 구현)
            } label: {
                Label("삭제", systemImage: "trash")
            }
        }
    }
}

// 빈 루틴 표시 컴포넌트
struct EmptyRoutineView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 64))
                .foregroundColor(Color.gray.opacity(0.5))
            
            Text("해당 요일에 등록된 루틴이 없습니다.")
                .font(.custom("Pretendard", size: 16))
                .foregroundColor(.gray)
            
            Text("루틴 추가 버튼을 눌러 새 루틴을 추가해보세요.")
                .font(.custom("Pretendard", size: 14))
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// 요일/날짜 선택 컴포넌트
struct RoutineDaySelector: View {
    @Binding var selectedDay: DayOfWeek
    var todayDate: String
    
    var body: some View {
        VStack(spacing: 0) {
            // 타이틀과 날짜
            HStack {
                Text("루틴 설정")
                    .font(.custom("Pretendard", size: 20).weight(.semibold))
                    .foregroundColor(.black)
                Spacer()
                Text(todayDate)
                    .font(.custom("Pretendard", size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 14)
            
            // 요일 선택 버튼
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 11) {
                    ForEach(DayOfWeek.allCases) { day in
                        DayButton(day: day, isSelected: selectedDay == day) {
                            selectedDay = day
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 30.1, y: 4)
        )
        .padding(.horizontal)
    }
}

// 요일 버튼 컴포넌트
struct DayButton: View {
    let day: DayOfWeek
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                ZStack {
                    RoundedRectangle(cornerRadius: 29.5)
                        .fill(isSelected ? Color(red: 0.15, green: 0.75, blue: 0) : Color(red: 0.94, green: 0.94, blue: 0.94))
                        .frame(width: 41, height: 58)
                    
                    Text(day.rawValue)
                        .font(.custom("Pretendard", size: 18).weight(.semibold))
                        .foregroundColor(isSelected ? .white : Color(red: 0.62, green: 0.62, blue: 0.62))
                }
            }
        }
    }
}

// 루틴 추가 시트
struct AddRoutineView: View {
    @ObservedObject var viewModel: RoutineViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String = ""
    @State private var time: String = "알림 없음"
    @State private var selectedDays: Set<DayOfWeek> = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("루틴 정보")) {
                    TextField("루틴 이름", text: $title)
                    
                    // 실제 구현에서는 DatePicker 등을 사용할 수 있음
                    TextField("알림 시간", text: $time)
                }
                
                Section(header: Text("반복 요일")) {
                    ForEach(DayOfWeek.allCases) { day in
                        HStack {
                            Text(day.rawValue + "요일")
                            Spacer()
                            if selectedDays.contains(day) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedDays.contains(day) {
                                selectedDays.remove(day)
                            } else {
                                selectedDays.insert(day)
                            }
                        }
                    }
                }
            }
            .navigationTitle("새 루틴 추가")
            .navigationBarItems(
                leading: Button("취소") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("저장") {
                    if !title.isEmpty && !selectedDays.isEmpty {
                        viewModel.addRoutine(title: title, time: time, days: selectedDays)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(title.isEmpty || selectedDays.isEmpty)
            )
        }
    }
}

#Preview {
    RoutineSettingsView()
}

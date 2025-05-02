import SwiftUI

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
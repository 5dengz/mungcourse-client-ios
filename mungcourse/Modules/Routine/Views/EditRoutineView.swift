import SwiftUI
import Combine

struct EditRoutineView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var title: String
    @State private var selectedDays: Set<DayOfWeek>
    @State private var isAM: Bool
    @State private var hour: Int
    @State private var minute: Int
    @State private var cancellables = Set<AnyCancellable>()
    let routine: Routine
    let onComplete: () -> Void

    init(routine: Routine, onComplete: @escaping () -> Void) {
        self.routine = routine
        _title = State(initialValue: routine.title)
        _selectedDays = State(initialValue: routine.days)
        // 시간 파싱
        let parts = routine.time.split(separator: ":")
        if parts.count == 2, let h24 = Int(parts[0]), let m = Int(parts[1]) {
            let isAM = h24 < 12
            let h12 = h24 % 12 == 0 ? 12 : h24 % 12
            _isAM = State(initialValue: isAM)
            _hour = State(initialValue: h12)
            _minute = State(initialValue: m)
        } else {
            _isAM = State(initialValue: true)
            _hour = State(initialValue: 8)
            _minute = State(initialValue: 0)
        }
        self.onComplete = onComplete
    }

    private var isFormValid: Bool {
        !title.isEmpty && !selectedDays.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            CommonHeaderView(
                leftIcon: "",
                leftAction: { presentationMode.wrappedValue.dismiss() },
                title: "루틴 수정"
            )
            .padding(.bottom, 12)
            .padding(.top, 32)
            .padding(.horizontal, 20)

            VStack(spacing: 28) {
                RequiredTextField(title: "루틴명", placeholder: "입력하기", text: $title)
                    .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 12) {
                    Text("반복 설정")
                        .font(.custom("Pretendard-SemiBold", size: 16))
                        .foregroundColor(Color("gray900"))
                        .padding(.leading, 20)
                    HStack(spacing: 16) {
                        ForEach(DayOfWeek.allCases, id: \.self) { day in
                            Circle()
                                .fill(selectedDays.contains(day) ? Color("main") : Color("gray200"))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Text(day.shortKor)
                                        .font(.custom("Pretendard-Bold", size: 14))
                                        .foregroundColor(selectedDays.contains(day) ? .white : Color("gray700"))
                                )
                                .onTapGesture {
                                    if selectedDays.contains(day) {
                                        selectedDays.remove(day)
                                    } else {
                                        selectedDays.insert(day)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("루틴 시간")
                        .font(.custom("Pretendard-SemiBold", size: 16))
                        .foregroundColor(Color("gray900"))
                        .padding(.leading, 20)
                    HStack(spacing: 0) {
                        Picker("오전/오후", selection: $isAM) {
                            Text("오전").tag(true)
                            Text("오후").tag(false)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 100)

                        Spacer()

                        Picker("시", selection: $hour) {
                            ForEach(1...12, id: \.self) { h in
                                Text("\(h)시").tag(h)
                            }
                        }
                        .frame(width: 80)
                        .tint(Color("main"))

                        Spacer()

                        Picker("분", selection: $minute) {
                            ForEach(0..<60, id: \.self) { m in
                                Text(String(format: "%02d분", m)).tag(m)
                            }
                        }
                        .frame(width: 80)
                        .tint(Color("main"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 20)

            Spacer()

            CommonFilledButton(
                title: "완료",
                action: updateRoutine,
                isEnabled: isFormValid
            )
            .padding(.horizontal, 40)
            .padding(.bottom, 28)
        }
    }

    private func updateRoutine() {
        let hour24 = isAM ? (hour % 12) : (hour % 12 + 12)
        let alarmTimeFormatted = String(format: "%02d:%02d", hour24, minute)
        let days = selectedDays.map { $0.apiValue }
        let applyFromDate = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: Date())
        }()
        let request = UpdateRoutineRequest(
            name: title,
            alarmTime: alarmTimeFormatted,
            repeatDays: days,
            isAlarmActive: true,
            applyFromDate: applyFromDate
        )
        RoutineService.shared.updateRoutine(routineId: routine.routineId, requestBody: request)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Failed to update routine:", error)
                }
            } receiveValue: {
                presentationMode.wrappedValue.dismiss()
                onComplete()
            }
            .store(in: &cancellables)
    }
}

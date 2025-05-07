import SwiftUI
import Combine

struct AddRoutineView: View {
    var onAdd: () -> Void
    @State private var title: String = ""
    @State private var selectedDays: Set<DayOfWeek> = []
    @State private var isAM: Bool = true
    @State private var hour: Int = 8
    @State private var minute: Int = 0
    @State private var isAlarmOn: Bool = false
    @State private var cancellables = Set<AnyCancellable>()
    
    private var isFormValid: Bool {
        !title.isEmpty && !selectedDays.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            CommonHeaderView(
                leftIcon: "",
                leftAction: { },
                title: "루틴 추가"
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
                                        .foregroundColor(selectedDays.contains(day) ? Color("pointwhite") : Color("gray700"))
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
                
                /* 알림 설정 섹션 주석 처리
                HStack {
                    Text("알림 설정")
                        .font(.custom("Pretendard-SemiBold", size: 16))
                        .foregroundColor(Color("gray900"))
                    Spacer()
                    Toggle("", isOn: $isAlarmOn)
                        .labelsHidden()
                }
                .padding(.horizontal, 20)
                */
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 20)

            Spacer()  // 버튼을 하단으로 밀기 위한 Spacer 삽입

            // '추가하기' 버튼
            CommonFilledButton(
                title: "추가하기",
                action: addRoutine,
                isEnabled: isFormValid
            )
            .padding(.horizontal, 40)
            .padding(.bottom, 28)
        }
    }

    private func addRoutine() {
        let hour24 = isAM ? (hour % 12) : (hour % 12 + 12)
        let alarmTimeFormatted = String(format: "%02d:%02d", hour24, minute)
        let days = selectedDays.map { $0.apiValue }
        let request = CreateRoutineRequest(
            name: title,
            alarmTime: alarmTimeFormatted,
            repeatDays: days,
            isAlarmActive: true
        )
        RoutineService.shared.createRoutine(requestBody: request)
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Failed to create routine:", error)
                }
            } receiveValue: { _ in
                onAdd()
            }
            .store(in: &cancellables)
    }
}
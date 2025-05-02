import SwiftUI

struct AddRoutineView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String = ""
    @State private var selectedDays: Set<DayOfWeek> = []
    @State private var isAM: Bool = true
    @State private var hour: Int = 8
    @State private var minute: Int = 0
    @State private var isAlarmOn: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            CommonHeaderView(
                leftIcon: "arrow_back",
                leftAction: { presentationMode.wrappedValue.dismiss() },
                title: "루틴 추가"
            )
            .padding(.bottom, 12)
            .padding(.top, 8)
            
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
                        
                        Picker("시", selection: $hour) {
                            ForEach(1...12, id: \.self) { h in
                                Text("\(h)시").tag(h)
                            }
                        }
                        .frame(width: 80)
                        .tint(Color("main"))
                        
                        Picker("분", selection: $minute) {
                            ForEach(0..<60, id: \.self) { m in
                                Text(String(format: "%02d분", m)).tag(m)
                            }
                        }
                        .frame(width: 80)
                        .tint(Color("main"))
                    }
                    .padding(.horizontal, 20)
                }
                
                HStack {
                    Text("알림 설정")
                        .font(.custom("Pretendard-SemiBold", size: 16))
                        .foregroundColor(Color("gray900"))
                    Spacer()
                    Toggle("", isOn: $isAlarmOn)
                        .labelsHidden()
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
            
            Spacer()
            
            CommonFilledButton(title: "홈으로 이동", action: {
                // 홈 이동 액션 구현 필요
                presentationMode.wrappedValue.dismiss()
            })
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }
}
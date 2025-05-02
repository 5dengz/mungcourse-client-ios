import SwiftUI

struct RequiredDatePicker: View {
    let title: String
    @Binding var selection: Date
    @State private var isShowingDatePicker = false
    
    // Date formatter for text display
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. MM. dd."
        return formatter
    }()
    
    var body: some View {
        InputFieldContainer(title: title) {
            HStack {
                Text(dateFormatter.string(from: selection))
                    .font(.custom("Pretendard-Regular", size: 14))
                    .foregroundColor(Color("black"))
                
                Spacer() // Pushes content to the left and right edges
                
                Image("icon_calendar")
                    .foregroundColor(Color("gray500"))
            }
            .inputBoxStyle() // Apply consistent styling
            .contentShape(Rectangle()) // Make the whole HStack tappable
            .onTapGesture {
                isShowingDatePicker = true
            }
            .sheet(isPresented: $isShowingDatePicker) {
                VStack(spacing: 20) {
                    Spacer().frame(height: 24) // 상단 여백 추가

                    DatePicker(
                        "날짜 선택",
                        selection: $selection,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding()
                    .tint(Color("main"))

                    CommonFilledButton(title: "확인", action: {
                        isShowingDatePicker = false
                    })
                    .padding(.horizontal)
                    .padding(.bottom, 16) // 하단 여백 추가
                    .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 8) } // 홈 인디케이터 보호

                    Spacer() // 버튼을 아래로 밀어줌
                }
                .presentationDetents([.height(500)])
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var selectedDate = Date()
        
        var body: some View {
            RequiredDatePicker(title: "필수 날짜 선택", selection: $selectedDate)
                .padding()
        }
    }
    return PreviewWrapper()
} 
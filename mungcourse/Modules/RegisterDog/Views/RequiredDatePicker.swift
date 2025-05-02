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
                    DatePicker(
                        "날짜 선택",
                        selection: $selection,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .labelsHidden()
                    .padding()
                    
                    Button("확인") {
                        isShowingDatePicker = false
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("main"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .presentationDetents([.height(400)])
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
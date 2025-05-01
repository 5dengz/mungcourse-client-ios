import SwiftUI

struct RequiredDatePicker: View {
    let title: String
    @Binding var selection: Date

    var body: some View {
         InputFieldContainer(title: title) {
             HStack {
                // Use DatePicker directly inline or as a button presenting a modal
                 DatePicker(
                    "", // No label needed here as we have the InputFieldContainer title
                    selection: $selection,
                    displayedComponents: [.date]
                 )
                 .labelsHidden() // Hide the default label
                 .font(.custom("Pretendard-Regular", size: 14))
                 .accentColor(Color("main")) // Picker accent color

                 Spacer() // Pushes date picker to the left
             }
             .inputBoxStyle() // Apply consistent styling
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
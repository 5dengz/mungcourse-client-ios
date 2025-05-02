import SwiftUI

struct RequiredPickerField: View {
    let title: String
    let placeholder: String
    @Binding var selection: String // Replace with appropriate type if using a real Picker
    
    // TODO: Implement actual Picker functionality (e.g., navigate to a selection list)
    var body: some View {
        InputFieldContainer(title: title) {
            HStack {
                Text(selection.isEmpty ? placeholder : selection)
                    .font(.custom("Pretendard-Regular", size: 14))
                    .foregroundColor(selection.isEmpty ? Color("gray500") : Color("black"))
                Spacer()
                Image("icon_search") // Changed from system icon to custom icon
                    .foregroundColor(Color("gray500"))
            }
            .inputBoxStyle()
            .contentShape(Rectangle()) // Make HStack tappable
            .onTapGesture {
                // TODO: Show picker view/options
                print("\(title) picker tapped")
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var sampleSelection: String = ""
        
        var body: some View {
            RequiredPickerField(title: "필수 선택", placeholder: "선택하세요", selection: $sampleSelection)
                .padding()
        }
    }
    return PreviewWrapper()
} 
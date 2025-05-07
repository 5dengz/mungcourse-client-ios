import SwiftUI

// --- Segmented Pickers ---
struct SegmentedButton<T: Hashable>: View {
    let option: T
    @Binding var selection: T?
    let text: String

    var isSelected: Bool { selection == option }

    var body: some View {
        Button {
            selection = option
        } label: {
            Text(text)
                .font(.custom(isSelected ? "Pretendard-Bold" : "Pretendard-Regular", size: 14))
                .frame(maxWidth: .infinity)
                .frame(height: 41)
                .foregroundColor(isSelected ? Color("pointwhite") : Color("gray600")) // Use asset colors
                .background(isSelected ? Color("main") : Color.clear) // Use asset colors
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.clear : Color("gray300"), lineWidth: 0.5) // Use asset colors
                )
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        enum SampleOption: String, CaseIterable {
            case optionA = "옵션 A"
            case optionB = "옵션 B"
        }
        @State var selectedOption: SampleOption? = .optionA
        
        var body: some View {
            HStack {
                SegmentedButton(option: SampleOption.optionA, selection: $selectedOption, text: SampleOption.optionA.rawValue)
                SegmentedButton(option: SampleOption.optionB, selection: $selectedOption, text: SampleOption.optionB.rawValue)
            }
            .padding()
        }
    }
    return PreviewWrapper()
} 
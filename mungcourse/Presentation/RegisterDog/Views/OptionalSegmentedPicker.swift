import SwiftUI

struct OptionalSegmentedPicker: View {
    let title: String
    @Binding var selection: Bool?

    var body: some View {
        InputFieldContainer(title: title) {
            HStack(spacing: 12) {
                SegmentedButton(option: true, selection: $selection, text: "예")
                SegmentedButton(option: false, selection: $selection, text: "아니오")
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var selection: Bool? = true
        
        var body: some View {
            OptionalSegmentedPicker(title: "선택적 예/아니오", selection: $selection)
                .padding()
        }
    }
    return PreviewWrapper()
} 
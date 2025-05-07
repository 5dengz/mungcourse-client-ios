import SwiftUI

struct RequiredSegmentedPicker<Option: RawRepresentable & Hashable & CaseIterable & Identifiable>: View where Option.RawValue == String {
    let title: String
    @Binding var selection: Option?
    let options: [Option] // Use the enum cases directly

    var body: some View {
        InputFieldContainer(title: title) {
            HStack(spacing: 12) { // Spacing between buttons
                ForEach(options) { option in
                     SegmentedButton(option: option, selection: $selection, text: option.rawValue)
                }
            }
        }
    }
}

// Define the enum inside the preview struct or globally if needed elsewhere
#Preview {
    struct PreviewWrapper: View {
        // Define Gender Enum specifically for the preview
        enum Gender: String, CaseIterable, Identifiable {
            case female = "여아"
            case male = "남아"
            var id: String { self.rawValue }
        }
        
        @State var selectedGender: Gender? = .female
        
        var body: some View {
            RequiredSegmentedPicker(title: "성별", selection: $selectedGender, options: Gender.allCases)
                .padding()
        }
    }
    return PreviewWrapper()
} 
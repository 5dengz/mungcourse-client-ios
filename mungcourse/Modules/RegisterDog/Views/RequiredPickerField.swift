import SwiftUI
import Foundation

struct RequiredPickerField: View {
    let title: String
    let placeholder: String
    @Binding var selection: String
    @State private var showBreedSearchView = false
    
    var body: some View {
        InputFieldContainer(title: title) {
            HStack {
                Text(selection.isEmpty ? placeholder : selection)
                    .font(.custom("Pretendard-Regular", size: 14))
                    .foregroundColor(selection.isEmpty ? Color("gray500") : Color("pointblack"))
                Spacer()
                Image("icon_search")
                    .foregroundColor(Color("gray500"))
            }
            .inputBoxStyle()
            .contentShape(Rectangle())
            .onTapGesture {
                showBreedSearchView = true
            }
            .fullScreenCover(isPresented: $showBreedSearchView) {
                DogBreedSearchView(
                    onBack: {
                        showBreedSearchView = false
                    },
                    onSelect: { breed in
                        selection = breed
                        showBreedSearchView = false
                    }
                )
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
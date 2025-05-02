import SwiftUI
import Foundation

struct RequiredPickerField: View {
    let title: String
    let placeholder: String
    @Binding var selection: String
    @State private var isShowingPicker = false
    
    var body: some View {
        InputFieldContainer(title: title) {
            HStack {
                Text(selection.isEmpty ? placeholder : selection)
                    .font(.custom("Pretendard-Regular", size: 14))
                    .foregroundColor(selection.isEmpty ? Color("gray500") : Color("black"))
                Spacer()
                Image("icon_search")
                    .foregroundColor(Color("gray500"))
            }
            .inputBoxStyle()
            .contentShape(Rectangle())
            .onTapGesture {
                isShowingPicker = true
            }
            .sheet(isPresented: $isShowingPicker) {
                NavigationView {
                    List(DogBreeds.all, id: \.self) { breed in
                        Button(action: {
                            selection = breed
                            isShowingPicker = false
                        }) {
                            HStack {
                                Text(breed)
                                    .foregroundColor(.black)
                                if selection == breed {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color("main"))
                                }
                            }
                        }
                    }
                    .navigationTitle(title)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("닫기") {
                                isShowingPicker = false
                            }
                        }
                    }
                }
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
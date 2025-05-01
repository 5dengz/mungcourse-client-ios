import SwiftUI

struct RegisterDogView: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var breed: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("반려견 이름")) {
                    TextField("이름을 입력하세요", text: $name)
                }
                Section(header: Text("나이")) {
                    TextField("나이를 입력하세요", text: $age)
                        .keyboardType(.numberPad)
                }
                Section(header: Text("품종")) {
                    TextField("품종을 입력하세요", text: $breed)
                }
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("반려견 등록")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("등록") {
                        registerAction()
                    }
                    .disabled(name.isEmpty || age.isEmpty || breed.isEmpty || viewModel.isLoading)
                }
            }
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
    }
    
    private func registerAction() {
        guard let ageInt = Int(age) else {
            viewModel.errorMessage = "유효한 나이를 입력해주세요."
            return
        }
        viewModel.registerDog(name: name, age: ageInt, breed: breed)
    }
}

#Preview {
    RegisterDogView(viewModel: LoginViewModel())
} 
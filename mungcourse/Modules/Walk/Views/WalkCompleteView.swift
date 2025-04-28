import SwiftUI

struct WalkCompleteView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(Color("main"))
            Text("산책이 완료되었습니다!")
                .font(.title2)
                .fontWeight(.bold)
            Text("수고하셨습니다. 기록을 확인해보세요.")
                .font(.body)
                .foregroundColor(.gray)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    WalkCompleteView()
}

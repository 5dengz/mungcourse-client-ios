import SwiftUI

struct ProfileTabView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("프로필 화면")
                .font(.title)
            Text("여기에 프로필 관련 내용을 추가하세요.")
                .foregroundColor(.gray)
        }
        .navigationTitle("프로필")
    }
}

#Preview {
    ProfileTabView()
}

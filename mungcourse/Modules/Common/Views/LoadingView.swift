import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color("gray900")
                .ignoresSafeArea() // 전체 화면을 배경색으로 채웁니다.

            Image("logo_white")
                .resizable()
                .scaledToFit()
                .frame(width: 210, height: 210) // 로고 크기 조절 (필요에 따라 조정)
        }
    }
}

#Preview {
    LoadingView()
}

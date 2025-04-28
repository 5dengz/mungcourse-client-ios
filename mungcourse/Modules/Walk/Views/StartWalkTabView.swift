import SwiftUI

struct StartWalkTabView: View {
    @State private var isActive = false
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                Image("start_walk")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                Text("오늘도 건강한 산책을 시작해볼까요?")
                    .font(.title3)
                    .fontWeight(.semibold)
                Button(action: { isActive = true }) {
                    Text("산책 시작하기")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                Spacer()
                NavigationLink(destination: StartWalkView(), isActive: $isActive) {
                    EmptyView()
                }
                .hidden()
            }
            .navigationTitle("산책 시작")
        }
    }
}

#Preview {
    StartWalkTabView()
}

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some View {
        VStack {
            Text("온보딩 화면")
                .font(.largeTitle)
                .padding()

            Button("온보딩 완료") {
                hasCompletedOnboarding = true
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    OnboardingView()
}

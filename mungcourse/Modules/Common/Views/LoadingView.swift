import SwiftUI

struct LoadingView: View {
    @State private var animateSmall = false
    @State private var animateMedium = false
    @State private var animateLarge = false
    
    var loadingText: String = ""  // 로딩 텍스트 파라미터 추가

    var body: some View {
        ZStack {
            Color("main")
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Image("logo_main")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 119, height: 93)
                    .overlay(alignment: .bottom) {
                        ZStack {
                            Image("ellipse_small")
                                .resizable()
                                .frame(width: 86, height: 34)
                                .scaleEffect(animateSmall ? 1 : 0)

                            Image("ellipse_medium")
                                .resizable()
                                .frame(width: 131, height: 51)
                                .scaleEffect(animateMedium ? 1 : 0)

                            Image("ellipse_large")
                                .resizable()
                                .frame(width: 176, height: 69)
                                .scaleEffect(animateLarge ? 1 : 0)
                        }
                        .offset(y: 34.5)
                    }
                
                // 로딩 텍스트 영역 추가
                if !loadingText.isEmpty {
                    Text(loadingText)
                        .font(Font.custom("Pretendard-Medium", size: 16))
                        .foregroundColor(Color("pointwhite"))
                        .padding(.top, 10)
                }
            }
        }
        .onAppear {
            animateSequence()
        }
    }

    private func animateSequence() {
        animateSmall = false
        animateMedium = false
        animateLarge = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            withAnimation(.easeOut(duration: 0.3)) {
                animateSmall = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.3)) {
                animateMedium = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.3)) {
                animateLarge = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            animateSequence()
        }
    }
}

#Preview {
    LoadingView()
}

import SwiftUI

struct WalkHeaderView: View {
    let onBack: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top
            VStack(spacing: 0) {
                ZStack {
                    Text("산책 시작")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                    HStack {
                        Button(action: onBack) {
                            Image("arrow_back")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .foregroundColor(Color("black"))
                        }
                        .padding(.leading, 16)
                        Spacer()
                        Color.clear.frame(width: 32) // 우측 여백 확보
                    }
                }
                .padding(.horizontal)
                .frame(height: 75)
                .padding(.top, topInset)
                .background(Color("white"))
                .shadow(color: Color("black").opacity(0.1), radius: 5, x: 0, y: 2)
                Spacer()
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
}

#if DEBUG
struct WalkHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        WalkHeaderView {
            // back
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif

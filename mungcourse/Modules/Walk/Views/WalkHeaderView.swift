import SwiftUI

struct WalkHeaderView: View {
    let onBack: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top
            VStack(spacing: 0) {
                CommonHeaderView(leftIcon: "arrow_back", leftAction: onBack, title: "산책 시작")
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

import SwiftUI

struct WalkHeaderView: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top
            VStack(spacing: 0) {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .foregroundColor("main")
                    }
                    Spacer()
                    Text(title)
                        .font(.headline)
                    Spacer()
                    Color.clear.frame(width: 24)
                }
                .padding(.horizontal)
                .frame(height: 75)
                .padding(.top, topInset)
                .background(Color(UIColor("gray900")))
                .shadow(color: Color("black10").opacity(0.1), radius: 5, x: 0, y: 2)
                Spacer()
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
}

#if DEBUG
struct WalkHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        WalkHeaderView(title: "산책 시작") {
            // back
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif 
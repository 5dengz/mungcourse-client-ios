import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            Color("main")
                .ignoresSafeArea()

            ZStack {
                Image("logo_main")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 119, height: 93)
                    .shadow(color: Color.black.opacity(0.18), radius: 16, x: 0, y: 8)
                    .overlay(alignment: .bottom) {
                        ZStack {
                            Image("ellipse_small")
                                .resizable()
                                .frame(width: 86, height: 34)
                            Image("ellipse_medium")
                                .resizable()
                                .frame(width: 131, height: 51)
                            Image("ellipse_large")
                                .resizable()
                                .frame(width: 176, height: 69)
                        }
                        .offset(y: 34.5)
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
    }
}

import SwiftUI

struct WalkControlButton: View {
    enum WalkState {
        case notStarted
        case active
        case paused
    }
    
    let state: WalkState
    let onStart: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onEnd: () -> Void
    
    var body: some View {
        HStack(spacing: 19) {
            switch state {
            case .active:
                Button(action: onPause) {
                    Image("button_stop")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 20)
                }
                .frame(width: 54, height: 54)
                .background(Color("main"))
                .clipShape(Circle())
            case .notStarted:
                Button(action: onStart) {
                    Image("button_play")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .frame(width: 54, height: 54)
                .background(Color("main"))
                .clipShape(Circle())
            case .paused:
                Button(action: onResume) {
                    Image("button_play")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .frame(width: 54, height: 54)
                .background(Color("main"))
                .clipShape(Circle())
            }

            // 산책 끝내기 버튼
            Button(action: onEnd) {
                Image("button_end")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
            .frame(width: 54, height: 54)
            .background(Color("white"))
            .clipShape(Circle())
            .shadow(color: Color("black").opacity(0.13), radius: 12, x: 2, y: 2)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

#Preview("Not Started") {
    WalkControlButton(
        state: .notStarted,
        onStart: {},
        onPause: {},
        onResume: {},
        onEnd: {}
    )
}

#Preview("Active") {
    WalkControlButton(
        state: .active,
        onStart: {},
        onPause: {},
        onResume: {},
        onEnd: {}
    )
}

#Preview("Paused", traits: .sizeThatFits) {
    WalkControlButton(
        state: .paused,
        onStart: {},
        onPause: {},
        onResume: {},
        onEnd: {}
    )
}

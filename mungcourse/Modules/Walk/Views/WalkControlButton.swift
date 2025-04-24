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
                    Image(systemName: "pause.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color("pointRed"))
                }
                .frame(width: 54, height: 54)
                .background(Color("main50"))
                .clipShape(Circle())
            case .notStarted:
                Button(action: onStart) {
                    Image(systemName: "play.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color("pointRed"))
                }
                .frame(width: 54, height: 54)
                .background(Color("main50"))
                .clipShape(Circle())
            case .paused:
                Button(action: onResume) {
                    Image(systemName: "play.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color("pointRed"))
                }
                .frame(width: 54, height: 54)
                .background(Color("main50"))
                .clipShape(Circle())
            }

            // 산책 끝내기 버튼
            Button(action: onEnd) {
                Image(systemName: "square.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color("main50"))
            }
            .frame(width: 54, height: 54)
            .background(Color("white"))
            .clipShape(Circle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color("gray900"))
    }
}

#Preview {
    Group {
        WalkControlButton(
            state: .notStarted,
            onStart: {},
            onPause: {},
            onResume: {},
            onEnd: {}
        )
        .previewDisplayName("Not Started")
        
        WalkControlButton(
            state: .active,
            onStart: {},
            onPause: {},
            onResume: {},
            onEnd: {}
        )
        .previewDisplayName("Active")
        
        WalkControlButton(
            state: .paused,
            onStart: {},
            onPause: {},
            onResume: {},
            onEnd: {}
        )
        .previewDisplayName("Paused")
    }
    .previewLayout(.sizeThatFits)
}
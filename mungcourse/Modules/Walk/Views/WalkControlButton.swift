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
        HStack(spacing: 24) {
            switch state {
            case .notStarted:
                // Just show the Start button when not started
                Button(action: onStart) {
                    Text("시작")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
            case .active:
                // Show Pause and End buttons when active
                Button(action: onPause) {
                    Text("일시정지")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(UIColor.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
                
                Button(action: onEnd) {
                    Text("완료")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
            case .paused:
                // Show Resume and End buttons when paused
                Button(action: onResume) {
                    Text("계속")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Button(action: onEnd) {
                    Text("완료")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(UIColor.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(UIColor.systemBackground))
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
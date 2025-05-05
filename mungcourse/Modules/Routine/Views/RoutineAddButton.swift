import SwiftUI

// 루틴 추가 버튼 컴포넌트
struct RoutineAddButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 24.5)
                    .fill(Color(red: 0.15, green: 0.75, blue: 0))
                    .frame(width: 111, height: 41)
                    .shadow(color: Color.black.opacity(0.15), radius: 16, y: 4)
                HStack(spacing: 5) {
                    Text("+")
                        .font(.custom("Pretendard", size: 18).weight(.bold))
                    Text("루틴 추가")
                        .font(.custom("Pretendard", size: 15).weight(.semibold))
                }
                .foregroundColor(.white)
            }
        }
    }
} 
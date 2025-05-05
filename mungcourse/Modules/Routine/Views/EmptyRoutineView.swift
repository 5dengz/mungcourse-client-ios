import SwiftUI

// 빈 루틴 표시 컴포넌트
struct EmptyRoutineView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 64))
                .foregroundColor(Color.gray.opacity(0.5))
            
            Text("등록된 루틴이 없습니다.")
                .font(.custom("Pretendard", size: 16))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 20)
        .padding(.top, 48)
        .frame(maxWidth: .infinity, alignment: .center)
    }
} 
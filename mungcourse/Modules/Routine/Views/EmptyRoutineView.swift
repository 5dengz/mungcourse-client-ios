import SwiftUI

// 빈 루틴 표시 컴포넌트
struct EmptyRoutineView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 64))
                .foregroundColor(Color.gray.opacity(0.5))
            
            Text("해당 요일에 등록된 루틴이 없습니다.")
                .font(.custom("Pretendard", size: 16))
                .foregroundColor(.gray)
            
            Text("루틴 추가 버튼을 눌러 새 루틴을 추가해보세요.")
                .font(.custom("Pretendard", size: 14))
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .center)
    }
} 
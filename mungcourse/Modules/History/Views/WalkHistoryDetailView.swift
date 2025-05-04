import SwiftUI

struct WalkHistoryDetailView: View {
    let date: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            CommonHeaderView(
                leftIcon: "arrow_back",
                leftAction: { dismiss() },
                title: "\(formatDate(date: date)) 산책 기록"
            )
            .font(.custom("Pretendard-SemiBold", size: 18))
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // 임시 콘텐츠
            VStack(spacing: 16) {
                Text("선택하신 날짜의 산책 기록입니다.")
                    .font(.custom("Pretendard-Regular", size: 16))
                    .padding(.top, 40)
                
                Text("산책 거리: 2.5km")
                    .font(.custom("Pretendard-Regular", size: 14))
                    .foregroundColor(Color("gray400"))
                    .padding(.top, 10)
                
                Text("산책 시간: 45분")
                    .font(.custom("Pretendard-Regular", size: 14))
                    .foregroundColor(Color("gray400"))
                    .padding(.top, 5)
                
                Text("소모 칼로리: 150kcal")
                    .font(.custom("Pretendard-Regular", size: 14))
                    .foregroundColor(Color("gray400"))
                    .padding(.top, 5)
                
                // 산책 경로 지도가 표시될 영역 (임시)
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("gray300"))
                    .frame(height: 250)
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .overlay(
                        Text("산책 경로 지도")
                            .foregroundColor(Color("gray600"))
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.top, 20)
            
            Spacer()
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
    
    // 날짜 포맷팅 함수 (yyyy년 MM월 dd일)
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        WalkHistoryDetailView(date: Date())
    }
}
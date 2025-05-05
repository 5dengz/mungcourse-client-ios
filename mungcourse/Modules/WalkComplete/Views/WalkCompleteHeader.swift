import SwiftUI

struct WalkCompleteHeader: View {
    let walkDate: Date
    let onClose: () -> Void
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: walkDate)
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate)
                    .font(.custom("Pretendard", size: 16).weight(.semibold))
                    .foregroundColor(Color("pointblack"))
                Text("오늘도 무사히")
                    .font(.custom("Pretendard", size: 24))
                    .foregroundColor(Color("pointblack"))
                Text("산책 완료!")
                    .font(.custom("Pretendard", size: 24).weight(.semibold))
                    .foregroundColor(Color("main"))
            }
            Spacer()
            VStack {
                Spacer()
                Image("profile_empty")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 84, height: 84)
                    .clipShape(Circle())
                    .background(Circle().fill(Color("gray200")))
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.top, 24)
        .padding(.bottom, 12)
        .frame(height: 160)
        .background(Color("white"))
        .shadow(color: Color("black").opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    WalkCompleteHeader(walkDate: Date(), onClose: {})
}

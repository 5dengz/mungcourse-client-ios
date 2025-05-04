import SwiftUI

struct AccountDeletionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedReason: String?
    @State private var reasonText: String = ""
    
    let reasons = ["기능이 다양하지 않아요", "배터리 소모가 너무 심해요", "추천 경로가 마음에 들지 않아요", "경로 측정이 잘 안 돼요", "기타"]

    var body: some View {
        VStack(spacing: 0) {
            CommonHeaderView(
                leftIcon: "arrow_back",
                leftAction: { dismiss() },
                title: "회원 탈퇴"
            )
            .padding(.bottom, 34)
            
            VStack(spacing: 0) {
                Text("탈퇴 이유를 알려주세요")
                    .font(.custom("Pretendard-SemiBold", size: 18))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 28)
                
                VStack(spacing: 16) {
                    ForEach(reasons, id: \.self) { reason in
                        ReasonItemView(
                            text: reason,
                            isSelected: selectedReason == reason
                        )
                        .onTapGesture {
                            selectedReason = reason
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                if selectedReason == "기타" {
                    VStack(alignment: .leading) {
                        TextField("상세 이유를 적어주세요", text: $reasonText)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                    }
                    .background(Color.white)
                }
                
                Button(action: {
                    // 탈퇴 처리 로직
                }) {
                    Text("탈퇴하기")
                        .font(.custom("Pretendard-Medium", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color("pointRed"))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .padding(.top, 30)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .ignoresSafeArea(edges: .bottom)
    }
}

struct ReasonItemView: View {
    let text: String
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 330, height: 57)
                .background(.white)
                .cornerRadius(12)
                .shadow(
                    color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), 
                    radius: 12, 
                    y: 2
                )
            
            Text(text)
                .font(Font.custom("Pretendard", size: 14))
                .foregroundColor(.black)
                .offset(x: -49.50, y: 0)
            
            if isSelected {
                Ellipse()
                    .foregroundColor(.clear)
                    .frame(width: 22, height: 22)
                    .background(Color(red: 0.15, green: 0.75, blue: 0))
                    .overlay(
                        Ellipse()
                            .inset(by: 0.50)
                            .stroke(Color(red: 0.15, green: 0.75, blue: 0), lineWidth: 0.50)
                    )
                    .offset(x: -137, y: -0.50)
            }
        }
        .frame(width: 330, height: 57)
    }
}

#if DEBUG
struct AccountDeletionView_Previews: PreviewProvider {
    static var previews: some View {
        AccountDeletionView()
    }
}
#endif
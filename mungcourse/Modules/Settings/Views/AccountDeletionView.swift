import SwiftUI

struct AccountDeletionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedReason: String?
    @State private var reasonText: String = ""
    
    let reasons = ["더 이상 서비스가 필요하지 않음", "사용성이 불편함", "개인정보 보호 문제", "더 좋은 대체 서비스를 찾음", "기타"]

    var body: some View {
        VStack(spacing: 0) {
            CommonHeaderView(
                leftIcon: "arrow_back",
                leftAction: { dismiss() },
                title: "회원 탈퇴"
            )
            .padding(.bottom, 28)
            
            VStack(spacing: 0) {
                HStack {
                    Text("탈퇴 이유를 알려주세요")
                        .font(.custom("Pretendard-Medium", size: 16))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
                .background(Color.white)
                
                VStack(spacing: 15) {
                    ForEach(reasons, id: \.self) { reason in
                        HStack {
                            Text(reason)
                                .font(.custom("Pretendard-Regular", size: 16))
                                .foregroundColor(.black)
                            Spacer()
                            if selectedReason == reason {
                                Image("icon_check")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 16)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedReason = reason
                        }
                    }
                }
                .padding(.vertical, 10)
                .background(Color.white)
                
                if selectedReason == "기타" {
                    VStack(alignment: .leading) {
                        TextField("상세 이유를 적어주세요", text: $reasonText)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
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

#if DEBUG
struct AccountDeletionView_Previews: PreviewProvider {
    static var previews: some View {
        AccountDeletionView()
    }
}
#endif
import SwiftUI

struct AccountDeletionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedReasons: Set<String> = []
    @State private var showConfirmation = false
    
    let reasons = ["기능이 다양하지 않아요", "배터리 소모가 너무 심해요", "추천 경로가 마음에 들지 않아요", "경로 측정이 잘 안 돼요", "기타"]

    var body: some View {
        VStack(spacing: 0) {
            CommonHeaderView(
                leftIcon: "arrow_back",
                leftAction: { dismiss() },
                title: "회원 탈퇴"
            )
            .padding(.top, 16)
            .padding(.bottom, 28)
            
            VStack(spacing: 0) {
                Text("탈퇴 이유를 알려주세요")
                    .font(.custom("Pretendard-SemiBold", size: 18))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 24)
                
                VStack(spacing: 16) {
                    ForEach(reasons, id: \.self) { reason in
                        ReasonItemView(
                            text: reason,
                            isSelected: selectedReasons.contains(reason),
                            onSelect: {
                                toggleSelection(reason)
                            }
                        )
                    }
                }
                
                Spacer()
                
                CommonFilledButton(
                    title: "계속하기",
                    action: {
                        // 탈퇴 확인 화면으로 이동
                        showConfirmation = true
                    },
                    isEnabled: !selectedReasons.isEmpty,
                    backgroundColor: Color("main"),
                    cornerRadius: 8
                )
                .padding(.bottom, 48)
            }
        }
        .padding(.horizontal, 16)
        .ignoresSafeArea(edges: .bottom)
        .fullScreenCover(isPresented: $showConfirmation) {
            AccountDeletionConfirmView(onDelete: {
                // 실제 회원 탈퇴 처리 로직
                dismiss() // 탈퇴 후 이전 화면으로 돌아가기
            })
        }
    }
    
    private func toggleSelection(_ reason: String) {
        if selectedReasons.contains(reason) {
            selectedReasons.remove(reason)
        } else {
            selectedReasons.insert(reason)
        }
    }
}

struct ReasonItemView: View {
    let text: String
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Text(text)
                .font(Font.custom("Pretendard", size: 14))
                .foregroundColor(.black)
                .padding(.leading, 16)
            
            Spacer()
            
            // 선택 버튼
            Button(action: onSelect) {
                ZStack {
                    Circle()
                        .stroke(Color("main"), lineWidth: 1)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Circle()
                            .fill(Color("main"))
                            .frame(width: 22, height: 22)
                        
                        Image("icon_check")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 22, height: 22)
                            .foregroundColor(Color("pointwhite"))
                    }
                }
            }
            .padding(.trailing, 16)
        }
        .frame(width: 330, height: 57)
        .background(
            Rectangle()
                .foregroundColor(Color("pointwhite"))
                .cornerRadius(12)
                .shadow(
                    color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), 
                    radius: 12, 
                    y: 2
                )
        )
    }
}

#if DEBUG
struct AccountDeletionView_Previews: PreviewProvider {
    static var previews: some View {
        AccountDeletionView()
    }
}
#endif
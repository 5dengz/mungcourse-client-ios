import SwiftUI

struct AccountDeletionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedReasons: Set<String> = []
    @State private var showConfirmation = false
    
    let reasons = ["기능이 다양하지 않아요", "배터리 소모가 너무 심해요", "추천 경로가 마음에 들지 않아요", "경로 측정이 잘 안 돼요", "기타"]

    var body: some View {
        VStack(spacing: 0) {
            // 1. 헤더 (상단 고정)
            CommonHeaderView(
                leftIcon: "arrow_back",
                leftAction: { dismiss() },
                title: "회원 탈퇴"
            )
            .padding(.top, 16)
            .padding(.bottom, 28)
            
            // 2. 중간 영역 (남은 공간 모두 차지)
            VStack(spacing: 0) {
                // 제목
                Text("탈퇴 이유를 알려주세요")
                    .font(.custom("Pretendard-SemiBold", size: 18))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 24)
                
                // 목록 (남은 공간 모두 차지)
                VStack(spacing: 16) {
                    ForEach(reasons, id: \.self) { reason in
                        ReasonItemView(
                            text: reason,
                            isSelected: selectedReasons.contains(reason),
                            onSelect: {
                                toggleSelection(reason)
                            }
                        )
                        .padding(.horizontal, 4) // 그림자를 위한 여백 추가
                    }
                    
                    Spacer() // 남은 공간 채우기
                }
                .padding(.horizontal, 12) // 바깥쪽 여백 추가
            }
            .padding(.horizontal, 16)
            .frame(maxHeight: .infinity) // 중간 영역이 남은 공간 모두 차지
            
            // 3. 하단 버튼 (하단 고정)
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
            .frame(width: UIScreen.main.bounds.width - 32)
            .padding(.top, 20)
            .padding(.bottom, 48)
            
        }
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
        .frame(maxWidth: .infinity)
        .frame(height: 57) // 고정 높이로 변경하여 계산을 정확하게
        .background(
            Rectangle()
                .foregroundColor(Color("pointwhite"))
                .cornerRadius(12)
                .shadow(
                    color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), 
                    radius: 4, 
                    x: 3,
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
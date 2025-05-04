import SwiftUI

/// 재사용 가능한 커스텀 팝업 모달
struct CommonPopupModal: View {
    let title: String
    let message: String
    let cancelText: String
    let confirmText: String
    let cancelAction: () -> Void
    let confirmAction: () -> Void
    
    init(
        title: String,
        message: String,
        cancelText: String = "취소",
        confirmText: String = "확인",
        cancelAction: @escaping () -> Void,
        confirmAction: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.cancelText = cancelText
        self.confirmText = confirmText
        self.cancelAction = cancelAction
        self.confirmAction = confirmAction
    }
    
    var body: some View {
        ZStack {
            // 배경 반투명 효과
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            // 모달 콘텐츠
            VStack(spacing: 20) {
                // 제목
                Text(title)
                    .font(.custom("Pretendard-SemiBold", size: 20))
                    .foregroundColor(.black)
                    .padding(.top, 24)
                
                // 메시지 텍스트
                Text(message)
                    .font(.custom("Pretendard-Regular", size: 14))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                // 버튼 영역
                HStack(spacing: 12) {
                    // 취소 버튼
                    Button(action: cancelAction) {
                        Text(cancelText)
                            .font(.custom("Pretendard-Bold", size: 16))
                            .foregroundColor(Color("gray600"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color("gray300"))
                            .cornerRadius(8)
                    }
                    
                    // 확인 버튼
                    Button(action: confirmAction) {
                        Text(confirmText)
                            .font(.custom("Pretendard-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color("main"))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 40)
            .shadow(color: Color.black.opacity(0.1), radius: 10)
        }
    }
}

#if DEBUG
struct CommonPopupModal_Previews: PreviewProvider {
    static var previews: some View {
        CommonPopupModal(
            title: "회원 탈퇴",
            message: "회원 탈퇴 시 반려견 정보 및 산책 기록은\n모두 삭제되어 복구가 불가해요\n\n정말로 삭제하시겠어요?",
            cancelAction: {},
            confirmAction: {}
        )
    }
}
#endif
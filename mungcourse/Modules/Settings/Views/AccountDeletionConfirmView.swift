import SwiftUI

struct AccountDeletionConfirmView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더 (AccountDeletionView와 동일)
            CommonHeaderView(
                leftIcon: "arrow_back",
                leftAction: { dismiss() },
                title: "회원 탈퇴"
            )
            .padding(.bottom, 28)
            
            VStack(spacing: 30) {
                // 본문 텍스트
                Text("잠시만요!\n탈퇴하시면 소중한 산책 기록이\n영영 사라져요 😢")
                    .font(.custom("Pretendard-SemiBold", size: 18))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 34)
                
                Spacer()
                
                // 하단 버튼: 취소 및 탈퇴하기
                VStack(spacing: 12) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("취소")
                            .font(.custom("Pretendard-Bold", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color("main"))
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        isLoading = true
                        // 실제 탈퇴 처리는 여기서 진행
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            isLoading = false
                            onDelete()
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color("gray100"))
                                .cornerRadius(8)
                        } else {
                            Text("탈퇴하기")
                                .font(.custom("Pretendard-Bold", size: 18))
                                .foregroundColor(Color("gray700"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color("gray100"))
                                .cornerRadius(8)
                        }
                    }
                    .disabled(isLoading)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 48)
            }
        }
        .padding(.horizontal, 16)
        .ignoresSafeArea(edges: .bottom)
    }
}

#if DEBUG
struct AccountDeletionConfirmView_Previews: PreviewProvider {
    static var previews: some View {
        AccountDeletionConfirmView(onDelete: {})
    }
}
#endif
import SwiftUI

struct PrivacyConsentView: View {
    let onAccept: () -> Void
    
    // 개인정보 처리 방침 텍스트
    private let privacyPolicyText = "개인정보처리방침\n\n'멍코스'는 「개인정보 보호법」 제30조에 따라 이용자의 개인정보를 보호하고 권익을 보호하며, 관련한 고충을 원활하게 처리할 수 있도록 다음과 같은 개인정보 처리방침을 수립·공개합니다.\n\n1. 개인정보의 처리 목적\n\n'멍코스'는 아래의 목적을 위하여 개인정보를 처리합니다. 처리한 개인정보는 다음의 목적 이외의 용도로는 사용되지 않으며, 이용 목적이 변경될 시에는 사전 동의를 받겠습니다.\n\n· 사용자 위치 기반의 맞춤형 산책 경로 추천 서비스 제공\n· 서비스 내 기능 개선 및 사용자 편의 향상\n\n2. 처리하는 개인정보의 항목\n\n· 수집 항목: GPS 위치정보(위도, 경도)\n· 수집 방법: 앱 실행 중 사용자 동의 후 자동 수집\n\n3. 개인정보의 처리 및 보유 기간\n\n· 수집된 개인정보는 서비스 이용 기간 동안만 보관되며,\n· 회원 탈퇴 또는 위치정보 수집 동의 철회 시 즉시 파기됩니다.\n\n4. 개인정보의 파기절차 및 파기방법\n\n'멍코스'는 개인정보 보유 기간이 경과했거나, 처리 목적이 달성된 경우에는 지체 없이 해당 정보를 파기합니다.\n\n· 파기절차: 이용자가 탈퇴하거나 위치정보 수집 동의를 철회한 경우, 관련 정보를 즉시 삭제 처리합니다.\n· 파기방법: 전자적 파일 형태로 저장된 개인정보는 기술적 방법을 이용하여 복원이 불가능한 방식으로 영구 삭제합니다.\n\n5. 정보주체와 법정대리인의 권리·의무 및 그 행사방법\n\n· 사용자는 언제든지 위치정보 수집에 대한 동의를 철회할 수 있으며, 앱 내 설정 또는 서비스 탈퇴를 통해 개인정보 삭제를 요청할 수 있습니다.\n· 법정대리인은 만 14세 미만 아동에 대한 권리를 행사할 수 있습니다.\n\n6. 개인정보의 안정성 확보 조치\n\n'멍코스'는 개인정보의 안전성 확보를 위해 다음과 같은 조치를 취하고 있습니다.\n\n· 기술적 조치: GPS 데이터 접근 제어\n· 관리적 조치: 개인정보 보호 교육 실시, 접근 권한 최소화\n· 물리적 조치: 서버 접근 통제 및 보안 유지\n\n7. 개인정보처리방침 변경에 관한 사항\n\n본 개인정보처리방침은 관련 법령 및 서비스 변경에 따라 개정될 수 있습니다. 변경 시 앱 또는 웹사이트 공지사항을 통해 사전 고지합니다.\n\n· 공고일자: 2025년 5월 6일\n· 시행일자: 2025년 5월 6일\n\n8. 개인정보 열람·정정·삭제·처리정지 요구권\n\n정보주체는 개인정보 열람, 정정, 삭제, 처리정지를 요구할 수 있으며, 해당 요청은 앱 내 설정 기능 또는 개인정보 보호책임자를 통해 처리됩니다."
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("gray100").ignoresSafeArea()
            VStack(spacing: 20) {
                Text("개인정보 보호 동의")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                ScrollView {
                    Text(privacyPolicyText)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .padding()
                }
                .frame(maxHeight: 500)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                Spacer()
                CommonFilledButton(
                    title: "수락",
                    action: onAccept
                )
            }
            .padding(.top, 50)
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
    }
}

#Preview {
    PrivacyConsentView(onAccept: { })
}
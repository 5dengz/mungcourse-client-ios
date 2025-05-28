import SwiftUI

struct VersionInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    // 앱 버전 정보 가져오기
    private var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "알 수 없음"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CommonHeaderView(
                leftIcon: "arrow_back",
                leftAction: { dismiss() },
                title: "버전 정보"
            )
            .padding(.top, 16)
            .padding(.bottom, 28)
            
            VStack(spacing: 24) {
                Text("멍코스(Mungcourse)")
                    .font(.custom("Pretendard-Bold", size: 24))
                    .foregroundColor(Color("pointblack"))
                
                Text("Odengz")
                    .font(.custom("Pretendard-Regular", size: 16))
                    .foregroundColor(Color.gray)
                
                Text("2025년")
                    .font(.custom("Pretendard-Regular", size: 14))
                    .foregroundColor(Color.gray)
                
                Text("버전 \(appVersion)")
                    .font(.custom("Pretendard-Regular", size: 14))
                    .foregroundColor(Color.gray)
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .bottom)
        .background(Color("pointwhite"))
    }
}

#if DEBUG
struct VersionInfoView_Previews: PreviewProvider {
    static var previews: some View {
        VersionInfoView()
    }
}
#endif

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var currentPage = 0
    @State private var showPrivacyConsent = false
    
    // 온보딩 페이지 데이터
    private let pages: [(mainTitle: String, subTitle: String, imageName: String)] = [
        (
            "AI 기반 코스 추천",
            "소중한 반려견에게 위험한 요소를 피해,\n안전한 산책 코스를 추천해줘요",
            "Image1"
        ),
        (
            "프로필도 간편하게 관리",
            "강아지가 많아도, 멍코스 하나면 충분해요.\n여러 반려견도 한 번에 간편하게 관리할 수 있어요.",
            "Image2"
        ),
        (
            "손쉬운 루틴 체크",
            "여러 반려견도 한 번에, 간편하게 관리할 수 있어요.\n산책 기록부터 체크리스트까지, 한눈에 확인해요.",
            "Image3"
        ),
        (
            "반려견의 산책 일지",
            "강아지와 함께한 산책을 소중히 기록해보세요.\n날짜, 거리, 기분까지 차곡차곡 쌓이는 나만의 멍로그!",
            "Image4"
        )
    ]
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color("gray100").ignoresSafeArea()
            // 메인 콘텐츠
            VStack {
                Spacer()
                
                // 페이지 컨텐츠
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(
                            mainTitle: pages[index].mainTitle,
                            subTitle: pages[index].subTitle,
                            imageName: pages[index].imageName
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // 페이지 인디케이터
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.main : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(10)
                
                // 다음 버튼
                CommonFilledButton(
                    title: currentPage < pages.count - 1 ? "다음" : "시작하기",
                    action: {
                        if currentPage < pages.count - 1 {
                            currentPage += 1
                        } else {
                            showPrivacyConsent = true
                        }
                    }
                )
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
            
            // 건너뛰기 버튼 - 최상위 레이어로 설정
            Button(action: {
                showPrivacyConsent = true
            }) {
                Text("건너뛰기")
                    .font(.custom("Pretendard-SemiBold", size: 15))
                    .foregroundColor(Color.gray600)
                    .padding(.top, 30)
                    .padding(.trailing, 30)
            }
            .zIndex(100) // z-인덱스를 높여서 항상 최상단에 표시
        }
        
        .fullScreenCover(isPresented: $showPrivacyConsent) {
            PrivacyConsentView(onAccept: {
                showPrivacyConsent = false
                completeOnboarding()
            })
        }
    }
    
    // 온보딩 완료 처리를 위한 함수
    private func completeOnboarding() {
        print("온보딩 완료 - 상태 변경 전: \(hasCompletedOnboarding)")
        hasCompletedOnboarding = true
        print("온보딩 완료 - 상태 변경 후: \(hasCompletedOnboarding)")
        
        // UserDefaults 값이 확실히 저장되도록 동기화
        UserDefaults.standard.synchronize()
        
        // 메인 스레드에서 상태 업데이트 보장
        DispatchQueue.main.async {
            // 상태 변경을 알리기 위한 노티피케이션 발송
            NotificationCenter.default.post(
                name: UserDefaults.didChangeNotification,
                object: nil
            )
        }
    }
}

#Preview {
    OnboardingView()
}

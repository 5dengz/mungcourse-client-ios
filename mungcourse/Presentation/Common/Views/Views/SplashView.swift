import SwiftUI
import Foundation
import Combine

struct SplashView: View {
    @EnvironmentObject var dogVM: DogViewModel
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var animateSmall = false
    @State private var animateMedium = false
    @State private var animateLarge = false
    @State private var shouldShowLogin = false
    @State private var shouldShowMain = false
    @State private var shouldShowRegisterDog = false
    @State private var splashStartTime: Date? = nil
    @State private var isNavigated = false
    @State private var showOnboarding = false

    var body: some View {
        ZStack {
            Color("main")
                .ignoresSafeArea()

            // 이미지 애니메이션 뷰를 화면 정중앙에 고정
            ZStack {
                Image("logo_main")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 119, height: 93)
                    .shadow(color: Color.black.opacity(0.18), radius: 16, x: 0, y: 8)
                    .overlay(alignment: .bottom) {
                        ZStack {
                            Image("ellipse_small")
                                .resizable()
                                .frame(width: 86, height: 34)
                                .scaleEffect(animateSmall ? 1 : 0)

                            Image("ellipse_medium")
                                .resizable()
                                .frame(width: 131, height: 51)
                                .scaleEffect(animateMedium ? 1 : 0)

                            Image("ellipse_large")
                                .resizable()
                                .frame(width: 176, height: 69)
                                .scaleEffect(animateLarge ? 1 : 0)
                        }
                        .offset(y: 34.5)
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            // 텍스트를 이미지뷰 위에 배치 (이미지 높이/2 + 여백만큼 위로 offset)
            AttributedText()
                .offset(y: -93/2 - 70) // 이미지 높이/2 + 여백(70)
        }
        .onAppear {
            splashStartTime = Date()
            animateSequence()
            dogVM.fetchDogs()
            // 온보딩 완료 여부 체크
            if !hasCompletedOnboarding {
                showOnboarding = true
            } else {
                checkTokenAndNavigate()
            }
        }
        .onChange(of: dogVM.dogs) { oldValue, newValue in
            if hasCompletedOnboarding {
                checkTokenAndNavigate()
            }
        }
        .fullScreenCover(isPresented: $showOnboarding, onDismiss: {
            // 온보딩이 끝나면 기존 분기 로직 실행
            checkTokenAndNavigate()
        }) {
            OnboardingView()
        }
        .fullScreenCover(isPresented: $shouldShowLogin) {
            LoginView()
        }
        .fullScreenCover(isPresented: $shouldShowMain) {
            ContentView().environmentObject(dogVM)
        }
        .fullScreenCover(isPresented: $shouldShowRegisterDog) {
            RegisterDogView(onComplete: {
                // 강아지 등록 완료 후 콜백 처리: 무조건 메인화면으로 이동
                print("[SplashView] 반려견 등록 완료: 콜백 실행")
                
                // 안전천막: 토큰 유효성을 확인하지만 결과에 상관없이 메인화면으로 이동
                TokenManager.shared.validateTokens()
                
                // 추가 디버깅 로그
                if let token = TokenManager.shared.getAccessToken(), !token.isEmpty {
                    print("[SplashView] 토큰 존재: \(token.prefix(10))... (유효성 \(isTokenValid(token) ? "있음" : "없음"))")
                } else {
                    print("[SplashView] 토큰 없음")
                }
                
                // 화면 전환 중복 방지
                resetCovers()
                
                // 강아지 정보 가져오기 후 무조건 메인 화면으로 이동
                dogVM.fetchDogs { 
                    print("[SplashView] 반려견 등록 완료: 메인 화면으로 이동")
                    shouldShowMain = true
                }
            }, onLogout: {
                // 로그아웃 시 처리
                print("[SplashView] 반려견 등록 화면에서 로그아웃")
                resetCovers()
                shouldShowLogin = true
            }, showBackButton: false)
            .environmentObject(dogVM)
        }
    }

    @ViewBuilder
    private func AttributedText() -> some View {
        (Text("멍코스")
            .font(.custom("Pretendard-SemiBold", size: 26))
        + Text("와 함께라면\n오늘도 안심 산책!")
            .font(.custom("Pretendard-Regular", size: 26)))
            .foregroundColor(Color("pointwhite"))
            .multilineTextAlignment(.center)
            .padding(.bottom, 20)
    }

    private func animateSequence() {
        animateSmall = false
        animateMedium = false
        animateLarge = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            withAnimation(.easeOut(duration: 0.3)) {
                animateSmall = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.3)) {
                animateMedium = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.3)) {
                animateLarge = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            animateSequence()
        }
    }

    private func showAfterMinimumSplash(_ action: @escaping () -> Void) {
        let minDuration: TimeInterval = 2.0
        let elapsed = Date().timeIntervalSince(splashStartTime ?? Date())
        if elapsed >= minDuration {
            if !isNavigated {
                isNavigated = true
                action()
            }
        } else {
            let delay = minDuration - elapsed
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if !isNavigated {
                    isNavigated = true
                    action()
                }
            }
        }
    }

    private func resetCovers() {
        shouldShowLogin = false
        shouldShowMain = false
        shouldShowRegisterDog = false
    }

    private func checkTokenAndNavigate() {
        // 토큰 존재 및 기본 유효성 확인
        if let token = TokenManager.shared.getAccessToken(), !token.isEmpty, isTokenValid(token) {
            print("[SplashView] 토큰 기본 검증 성공: 추가 검증 시작")
            
            // TokenManager를 통한 추가 토큰 검증
            if TokenManager.shared.validateTokens() {
                print("[SplashView] TokenManager 검증 성공: 화면 전환 진행")
                
                // 로그인 되어 있으면 강아지 목록 상태로 분기
                showAfterMinimumSplash {
                    resetCovers()
                    if dogVM.dogs.isEmpty {
                        // 강아지 등록 화면으로 전환 직전에 한번 더 토큰 검증
                        if TokenManager.shared.validateTokens() {
                            print("[SplashView] 강아지 등록 화면 전환 직전 토큰 재검증 성공")
                            shouldShowRegisterDog = true
                        } else {
                            print("[SplashView] 강아지 등록 화면 전환 직전 토큰 재검증 실패, 로그인으로 이동")
                            shouldShowLogin = true
                        }
                    } else {
                        shouldShowMain = true
                    }
                }
            } else {
                print("[SplashView] TokenManager 검증 실패: 토큰 갱신 시도")
                // 토큰 갱신 시도
                TokenManager.shared.refreshAccessToken { success in
                    if success {
                        print("[SplashView] 토큰 갱신 성공: 화면 전환 진행")
                        self.showAfterMinimumSplash {
                            self.resetCovers()
                            if self.dogVM.dogs.isEmpty {
                                // 토큰 갱신 후 강아지 등록 화면으로 전환 직전에 한번 더 검증
                                if TokenManager.shared.validateTokens() {
                                    self.shouldShowRegisterDog = true
                                } else {
                                    self.shouldShowLogin = true
                                }
                            } else {
                                self.shouldShowMain = true
                            }
                        }
                    } else {
                        print("[SplashView] 토큰 갱신 실패: 로그인으로 이동")
                        self.showAfterMinimumSplash {
                            self.resetCovers()
                            self.shouldShowLogin = true
                        }
                    }
                }
            }
        } else {
            print("[SplashView] 토큰 기본 검증 실패: 로그인으로 이동")
            showAfterMinimumSplash {
                resetCovers()
                shouldShowLogin = true
            }
        }
    }

    private func isTokenValid(_ token: String) -> Bool {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else { return false }
        var base64 = String(segments[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 = base64.padding(toLength: base64.count + 4 - remainder, withPad: "=", startingAt: 0)
        }
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return false
        }
        return Date(timeIntervalSince1970: exp) > Date()
    }
}

#Preview {
    SplashView()
}

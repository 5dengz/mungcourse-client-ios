//
//  mungcourseApp.swift
//  mungcourse
//
//  Created by Kyoungho Eom on 4/6/25.
//

import SwiftUI
import NMapsMap // 네이버 지도 SDK 임포트 (SwiftData 제거)

@main
struct mungcourseApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("authToken") private var authToken: String = "" // 추후 토큰 저장용
    @State private var showLoadingScreen = true // 로딩 화면 표시 여부

    // 앱 초기화 시 네이버 지도 SDK 인증
    init() {
        NMFAuthManager.shared().ncpKeyId = "5s28pgywc5" // Info.plist에 있는 클라이언트 ID와 동일하게 설정
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                // 로딩 완료 후 보여줄 메인 컨텐츠 결정
                if !showLoadingScreen {
                    // 토큰이 있으면 온보딩과 로그인 화면을 건너뛰고 바로 홈 화면으로 이동
                    if !authToken.isEmpty {
                        // 토큰이 유효한 경우 (추후 검증 로직 추가)
                        ContentView()
                    } else if !hasCompletedOnboarding {
                        // 1. 온보딩 미완료: 온보딩 화면 표시
                        OnboardingView()
                        // OnboardingView 내에서 완료 시 hasCompletedOnboarding = true 로 설정
                    } else if !isLoggedIn {
                        // 2. 온보딩 완료, 로그인 안 됨: 로그인 화면 표시
                        LoginView()
                        // LoginView 내에서 로그인 완료 시 isLoggedIn = true 로 설정
                    } else {
                        // 3. 로그인 완료: 메인 컨텐츠 표시
                        ContentView()
                    }
                }

                // 로딩 화면을 조건부로 위에 표시
                if showLoadingScreen {
                    LoadingView()
                        .transition(.opacity) // 부드러운 전환 효과
                        .zIndex(1) // 항상 위에 오도록 설정
                        .onAppear {
                            // 2초 후에 로딩 화면 숨김
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                print("Minimum time passed, hiding loading screen") // 디버깅 로그 추가
                                withAnimation {
                                    self.showLoadingScreen = false
                                }
                            }
                        }
                }
            }
        }
    }
}

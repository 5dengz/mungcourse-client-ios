//
//  mungcourseApp.swift
//  mungcourse
//
//  Created by Kyoungho Eom on 4/6/25.
//

import SwiftUI
import NMapsMap // 네이버 지도 SDK 임포트 (SwiftData 제거)
import GoogleSignIn

@main
struct mungcourseApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @StateObject private var tokenManager = TokenManager.shared
    @State private var showLoadingScreen = true // 로딩 화면 표시 여부
    @StateObject private var dogVM = DogViewModel()

    
    init() {
        GlobalLocationManager.shared.startUpdatingLocation() // 앱 시작 시 위치 업데이트 시작
        // Naver Maps Client ID를 Info.plist에서 직접 읽어옵니다.
        guard let naverId = Bundle.main.object(forInfoDictionaryKey: "NMFClientId") as? String, !naverId.isEmpty else {
            fatalError("NMFClientId not found in Info.plist")
        }
        NMFAuthManager.shared().ncpKeyId = naverId

        // GoogleSignIn Client ID를 Info.plist에서 직접 읽어옵니다.
        guard let googleId = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String, !googleId.isEmpty else {
            fatalError("GIDClientID not found in Info.plist")
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: googleId)

        // 디버깅: Info.plist에서 API_BASE_URL 값 확인
        let apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String
        print("[DEBUG] API_BASE_URL 런타임 값:", apiBaseURL ?? "nil")
    }

    var body: some Scene {
        WindowGroup {
            // 온보딩, 로그인, 메인 화면 분기
            if !hasCompletedOnboarding {
                OnboardingView()
            } else if tokenManager.accessToken == nil {
                LoginView()
            } else {
                SplashView()
                    .environmentObject(dogVM)
                    .preferredColorScheme(.light)
                    .background(Color("gray100").ignoresSafeArea())
            }
        }
    }
}

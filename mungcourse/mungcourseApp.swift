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
    @State private var forceUpdate: Bool = false // 강제 업데이트를 위한 상태

    
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
        
        // UserDefaults 변경사항 모니터링 설정
        NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            // 디버깅용 로그
            print("[DEBUG] UserDefaults 변경 감지: hasCompletedOnboarding =", UserDefaults.standard.bool(forKey: "hasCompletedOnboarding"))
        }
        // 앱 데이터 리셋(로그아웃/탈퇴) 시 싱글턴/뷰모델 초기화
        NotificationCenter.default.addObserver(
            forName: .appDataDidReset,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.dogVM.reset()
            self?.forceUpdate.toggle()
        }
    }

    var body: some Scene {
        WindowGroup {
            // 상태 값에 따라 뷰 표시 (forceUpdate를 사용하여 뷰 갱신 강제)
            Group {
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
            // 상태 변경을 감지하기 위해 UserDefaults 변경 알림을 수신
            .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
                // 메인 스레드에서 상태 업데이트 보장
                DispatchQueue.main.async {
                    // UserDefaults에서 직접 읽어와 상태 갱신
                    let newValue = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
                    if hasCompletedOnboarding != newValue {
                        print("[DEBUG] OnReceive - hasCompletedOnboarding 업데이트: \(hasCompletedOnboarding) -> \(newValue)")
                        hasCompletedOnboarding = newValue
                        // 강제 갱신 트리거
                        forceUpdate.toggle()
                    }
                }
            }
            .id(forceUpdate) // 상태가 변경될 때마다 View를 강제로 다시 그림
        }
    }
}

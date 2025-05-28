//
//  mungcourseApp.swift
//  mungcourse
//
//  Created by Kyoungho Eom on 4/6/25.
//

import SwiftUI
import NMapsMap // 네이버 지도 SDK 임포트 (SwiftData 제거)
import GoogleSignIn

// 알림 이름 확장
extension Notification.Name {
    static let appDataDidReset = Notification.Name("appDataDidReset") // 기존 알림명이 상수로 선언되지 않았다면 추가
    static let forceViewUpdate = Notification.Name("forceViewUpdate") // 새로운 알림 이름 추가
}

@main
struct mungcourseApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @StateObject private var tokenManager = TokenManager.shared
    @State private var showLoadingScreen = true // 로딩 화면 표시 여부
    @StateObject private var dogVM = DogViewModel()
    @State private var forceUpdate: Bool = false // 강제 업데이트를 위한 상태
    @Environment(\.scenePhase) private var scenePhase // 앱 라이프사이클 감지를 위한 환경 변수
    
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
        let dogVMCopy = dogVM // 로컬 상수에 저장
        NotificationCenter.default.addObserver(
            forName: .appDataDidReset,
            object: nil,
            queue: .main
        ) { [weak dogVMCopy] _ in
            Task { @MainActor in
                dogVMCopy?.reset()
            }
            // forceUpdate.toggle() 대신 알림 발행
            NotificationCenter.default.post(name: .forceViewUpdate, object: nil)
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
            // forceViewUpdate 알림을 감지하여 forceUpdate 상태 변경
            .onReceive(NotificationCenter.default.publisher(for: .forceViewUpdate)) { _ in
                forceUpdate.toggle()
            }
            // 앱 상태 변경 감지 (백그라운드에서 포그라운드로 전환 시 토큰 검증)
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active && oldPhase == .background {
                    // 백그라운드에서 포그라운드로 전환 시
                    print("[백그라운드-포그라운드 전환] 토큰 검증 수행")
                    
                    if !TokenManager.shared.validateTokens() {
                        print("[백그라운드-포그라운드 전환] 토큰 만료 감지, 갱신 시도")
                        TokenManager.shared.refreshAccessToken { success in
                            if !success {
                                // 갱신 실패 시 앱 리셋
                                DispatchQueue.main.async {
                                    print("[백그라운드-포그라운드 전환] 토큰 갱신 실패, 앱 리셋")
                                    NotificationCenter.default.post(name: .appDataDidReset, object: nil)
                                }
                            } else {
                                print("[백그라운드-포그라운드 전환] 토큰 갱신 성공")
                            }
                        }
                    }
                }
            }
        }
    }
}

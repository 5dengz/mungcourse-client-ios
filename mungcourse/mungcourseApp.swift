//
//  mungcourseApp.swift
//  mungcourse
//
//  Created by Kyoungho Eom on 4/6/25.
//

import SwiftUI
import SwiftData

@main
struct mungcourseApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showLoadingScreen = true // 로딩 화면 표시 여부

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                // 로딩 완료 후 보여줄 메인 컨텐츠 결정
                if !showLoadingScreen {
                    if hasCompletedOnboarding {
                        ContentView()
                            .modelContainer(sharedModelContainer)
                            // ContentView 로딩 관련 로직은 필요 시 ContentView 내부에서 처리
                    } else {
                        OnboardingView()
                        // OnboardingView 내에서 완료 시 hasCompletedOnboarding = true 로 설정
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

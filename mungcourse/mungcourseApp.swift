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
    @State private var isMinimumTimePassed = false // 최소 시간(2초) 경과 여부
    @State private var isContentLoaded = false   // ContentView 로드(표시) 여부

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
            if hasCompletedOnboarding {
                ZStack { // ZStack을 사용하여 뷰를 겹침
                    // ContentView는 항상 렌더링
                    ContentView()
                        .modelContainer(sharedModelContainer)
                        .onAppear {
                            // ContentView가 화면에 나타나면 isContentLoaded를 true로 설정
                            // 실제 앱에서는 데이터 로딩 완료 시점에 이 상태를 변경해야 더 정확합니다.
                            print("ContentView appeared, setting isContentLoaded to true") // 디버깅 로그 추가
                            self.isContentLoaded = true
                        }

                    // 로딩 조건 충족 시 LoadingView를 위에 표시
                    if !isMinimumTimePassed || !isContentLoaded {
                        LoadingView()
                            .transition(.opacity) // 부드러운 전환 효과 (선택 사항)
                            .zIndex(1) // LoadingView가 항상 위에 오도록 zIndex 설정
                            .onAppear {
                                // 2초 후에 isMinimumTimePassed를 true로 설정
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    print("Minimum time passed, setting isMinimumTimePassed to true") // 디버깅 로그 추가
                                    self.isMinimumTimePassed = true
                                }
                            }
                    }
                }
            } else {
                OnboardingView()
                // OnboardingView 내에서 완료 시 hasCompletedOnboarding = true 로 설정하는 로직 필요
            }
        }
    }
}

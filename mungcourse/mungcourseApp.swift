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
            // 최소 시간이 경과하지 않았거나, ContentView가 아직 로드되지 않았다면 LoadingView 표시
            if !isMinimumTimePassed || !isContentLoaded {
                LoadingView()
                    .onAppear {
                        // 2초 후에 isMinimumTimePassed를 true로 설정
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.isMinimumTimePassed = true
                        }
                    }
            } else {
                ContentView()
                    .modelContainer(sharedModelContainer) // ContentView에만 modelContainer 적용
                    .onAppear {
                        // ContentView가 화면에 나타나면 isContentLoaded를 true로 설정
                        // 실제 앱에서는 데이터 로딩 완료 시점에 이 상태를 변경해야 더 정확합니다.
                        self.isContentLoaded = true
                    }
            }
        }
    }
}

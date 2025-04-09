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
    @State private var isLoading = true // 로딩 상태를 관리하는 State 변수 추가
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
            if isLoading {
                LoadingView()
                    .onAppear {
                        // 2초 후에 로딩 상태를 false로 변경하여 ContentView 표시
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.isLoading = false
                        }
                    }
            } else {
                ContentView()
                    .modelContainer(sharedModelContainer) // ContentView에만 modelContainer 적용
            }
        }
        // WindowGroup 전체에 modelContainer를 적용하지 않고 ContentView에만 적용
    }
}

//
//  ContentView.swift
//  mungcourse
//
//  Created by Kyoungho Eom on 4/6/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // 각 탭에 새로 생성한 뷰를 연결합니다.
            HomeView()
                .tabItem {
                    Label {
                        Text("홈")
                    } icon: {
                        Image("home") // Asset Catalog 아이콘 사용
                    }
                }

            StartWalkView() // 분리된 뷰 사용
                .tabItem {
                    Label {
                        Text("산책 시작")
                    } icon: {
                        Image("map") // Asset Catalog 아이콘 사용
                    }
                }

            RoutineSettingsView() // 분리된 뷰 사용
                .tabItem {
                    Label {
                        Text("루틴 설정")
                    } icon: {
                        Image("route") // Asset Catalog 아이콘 사용
                    }
                }

            WalkHistoryView() // 분리된 뷰 사용
                .tabItem {
                    Label {
                        Text("산책 기록")
                    } icon: {   
                        Image("history") // Asset Catalog 아이콘 사용
                    }
                }

            ProfileTabView() // 분리된 뷰 사용
                .tabItem {
                    Label {
                        Text("프로필")
                    } icon: {
                        Image("profile") // Asset Catalog 아이콘 사용
                    }
                }
        }
        // .accentColor(themeColor) // 제거됨 - Asset Catalog의 AccentColor 사용
    }
}

// --- HomeView 및 Placeholder 뷰 정의는 HomeView.swift로 이동되었으므로 제거 ---


#Preview {
    ContentView()
    // SwiftData 관련 코드는 제거되었으므로 Preview에서도 제거합니다.
    // .modelContainer(for: Item.self, inMemory: true)
}

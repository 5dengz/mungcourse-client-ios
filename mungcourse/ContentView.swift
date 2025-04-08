//
//  ContentView.swift
//  mungcourse
//
//  Created by Kyoungho Eom on 4/6/25.
//

import SwiftUI

// 테마 색상 정의
let themeColor = Color(hex: "48CF6E")

struct ContentView: View {
    var body: some View {
        TabView {
            // 각 탭에 새로 생성한 뷰를 연결합니다.
            HomeView()
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }

            StartWalkView() // 분리된 뷰 사용
                .tabItem {
                    Label("산책 시작", systemImage: "figure.walk")
                }

            RoutineSettingsView() // 분리된 뷰 사용
                .tabItem {
                    Label("루틴 설정", systemImage: "gearshape.fill")
                }

            WalkHistoryView() // 분리된 뷰 사용
                .tabItem {
                    Label("산책 기록", systemImage: "list.bullet")
                }

            ProfileTabView() // 분리된 뷰 사용
                .tabItem {
                    Label("프로필", systemImage: "person.fill")
                }
        }
        .accentColor(themeColor) // 탭 바 아이콘 및 텍스트 색상 설정
    }
}

// --- HomeView 및 Placeholder 뷰 정의는 HomeView.swift로 이동되었으므로 제거 ---

// --- Helper Extension for Hex Color ---
// Color 확장은 다른 곳에서도 사용될 수 있으므로 유지하거나 별도 파일로 분리 가능
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


#Preview {
    ContentView()
    // SwiftData 관련 코드는 제거되었으므로 Preview에서도 제거합니다.
    // .modelContainer(for: Item.self, inMemory: true)
}

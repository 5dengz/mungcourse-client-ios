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
            HomeView()
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }

            Text("산책 시작 화면 (구현 예정)")
                .tabItem {
                    Label("산책 시작", systemImage: "figure.walk")
                }

            Text("루틴 설정 화면 (구현 예정)")
                .tabItem {
                    Label("루틴 설정", systemImage: "gearshape.fill")
                }

            Text("산책 기록 화면 (구현 예정)")
                .tabItem {
                    Label("산책 기록", systemImage: "list.bullet")
                }

            Text("프로필 화면 (구현 예정)")
                .tabItem {
                    Label("프로필", systemImage: "person.fill")
                }
        }
        .accentColor(themeColor) // 탭 바 아이콘 및 텍스트 색상 설정
    }
}

struct HomeView: View {
    var body: some View {
        ScrollView { // 내용이 길어질 수 있으므로 ScrollView 사용
            VStack(spacing: 20) { // 섹션 간 간격 설정
                ProfileArea()
                ButtonArea()
                NearbyTrailsArea()
                WalkIndexArea()
                PastRoutesArea()
                Spacer() // 남은 공간 채우기
            }
            .padding() // 전체적인 패딩 추가
        }
        .navigationTitle("홈") // 네비게이션 타이틀 설정 (필요시 NavigationView로 감싸야 함)
    }
}

// --- Placeholder Views ---

struct ProfileArea: View {
    var body: some View {
        Text("프로필 영역")
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
    }
}

struct ButtonArea: View {
    var body: some View {
        Text("버튼 영역")
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
    }
}

struct NearbyTrailsArea: View {
    var body: some View {
        Text("주변 산책로 영역")
            .frame(maxWidth: .infinity, minHeight: 150)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
    }
}

struct WalkIndexArea: View {
    var body: some View {
        Text("산책 지수 영역")
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
    }
}

struct PastRoutesArea: View {
    var body: some View {
        Text("지난 경로 영역")
            .frame(maxWidth: .infinity, minHeight: 150)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
    }
}

// --- Helper Extension for Hex Color ---
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

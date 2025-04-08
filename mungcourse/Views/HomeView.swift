import SwiftUI

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

// Preview for HomeView itself, if needed for isolated development
#Preview {
    HomeView()
}

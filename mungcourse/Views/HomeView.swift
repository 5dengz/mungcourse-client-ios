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
    // TODO: 실제 사용자 데이터로 교체 필요
    let userName = "클라인" // 임시 더미 데이터

    var body: some View {
        HStack(alignment: .top, spacing: 15) { // 상단 정렬 및 요소 간 간격
            (Text("반가워요\n") +
             Text(userName).fontWeight(.bold).foregroundColor(.accentColor) + // 사용자 이름 스타일 적용
             Text(" 보호자님!"))
                .font(.custom("Pretendard-Regular", size: 24)) // 전체 텍스트 기본 폰트 및 크기
                .lineSpacing(5) // 줄 간격 조절

            Spacer() // 텍스트와 이미지 사이 공간 최대화

            Image(systemName: "person.crop.circle.fill") // 시스템 프로필 아이콘 사용
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60) // 이미지 크기 설정
                .foregroundColor(.gray) // 아이콘 색상 설정
        }
        .padding() // HStack 내부 패딩 추가
        // .background(Color.gray.opacity(0.1)) // 필요하다면 배경색 추가
        // .cornerRadius(10) // 필요하다면 코너 라운딩 추가
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

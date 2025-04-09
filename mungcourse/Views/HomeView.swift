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
    // TODO: 실제 강아지 데이터 목록 로드 및 선택 로직 구현 필요
    @State private var dogName = "몽실이" // @State로 변경하여 값 변경 가능하도록 함
    // TODO: 실제 강아지 목록 데이터 필요
    let availableDogs = ["몽실이", "초코", "해피"] // 임시 강아지 목록
    @State private var showingDogSelection = false // 강아지 선택 다이얼로그 표시 상태

    var body: some View {
        HStack(alignment: .top, spacing: 15) { // 상단 정렬 및 요소 간 간격
            VStack(alignment: .leading, spacing: 5) { // 세로 정렬 및 간격
                Text("반가워요") // 첫 줄 분리
                    .font(.custom("Pretendard-Regular", size: 24))

                HStack(spacing: 8) { // 버튼과 "보호자님!" 텍스트를 가로로 묶음
                    Button {
                        showingDogSelection = true // 다이얼로그 표시
                        print("강아지 이름 변경 버튼 탭됨.")
                    } label: {
                        HStack(spacing: 4) { // 이름과 아이콘 가로 배치
                            Text(dogName)
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                            // .underline() // 표준 밑줄 제거

                        Image(systemName: "chevron.down") // 아래 화살표 아이콘 추가
                            .font(.caption) // 아이콘 크기 약간 작게
                            .foregroundColor(.accentColor) // 아이콘 색상 통일
                    }
                    .overlay( // 밑줄 효과를 위한 오버레이
                        Rectangle() // 사각형으로 밑줄 생성
                            .frame(height: 1) // 밑줄 두께
                            .offset(y: 3) // 텍스트 아래로 위치 조정 (값을 조절하여 간격 변경)
                            .foregroundColor(.accentColor), // 밑줄 색상
                            alignment: .bottomLeading // 텍스트 하단 왼쪽에 정렬
                        )
                    }
                    .font(.custom("Pretendard-Regular", size: 24)) // 버튼 내부 요소 폰트 적용
                    .buttonStyle(.plain) // 기본 버튼 스타일 제거하여 텍스트처럼 보이게 함

                    Text("보호자님!") // "보호자님!" 텍스트
                        .font(.custom("Pretendard-Regular", size: 24))
                } // HStack (버튼 + 보호자님!) 끝

                // --- 드롭다운 목록 코드 완전 제거 ---

            } // VStack (메인 텍스트 영역) 끝

            Spacer() // 텍스트 영역과 프로필 이미지 사이 공간 최대화

            Image(systemName: "person.crop.circle.fill") // 시스템 프로필 아이콘 사용
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60) // 이미지 크기 설정
                .foregroundColor(.gray) // 아이콘 색상 설정
        }
        .padding() // HStack 내부 패딩 추가
        // .background(Color.gray.opacity(0.1)) // 필요하다면 배경색 추가
        // .cornerRadius(10) // 필요하다면 코너 라운딩 추가
        .confirmationDialog("강아지 선택", isPresented: $showingDogSelection, titleVisibility: .visible) {
            // 사용 가능한 모든 강아지 목록을 버튼으로 표시
            ForEach(availableDogs, id: \.self) { name in
                Button(name) {
                    dogName = name // 선택된 이름으로 업데이트
                }
            }
            // 취소 버튼 (선택 사항이지만 추가하는 것이 좋음)
            Button("취소", role: .cancel) { }
        } message: {
            Text("함께 산책할 강아지를 선택해주세요.") // 다이얼로그 메시지 (선택 사항)
        }
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

// NearbyTrailsArea struct removed - moved to Components/NearbyTrailsArea.swift

struct WalkIndexArea: View {
    var body: some View {
        Text("산책 지수 영역")
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
    }
}

// PastRoutesArea struct removed - moved to Components/PastRoutesArea.swift

// Preview for HomeView itself, if needed for isolated development
#Preview {
    HomeView()
}

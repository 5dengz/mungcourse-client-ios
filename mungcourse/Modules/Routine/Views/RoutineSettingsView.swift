import SwiftUI

struct RoutineSettingsView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            // 상단 상태바
            RoutineStatusBar()
                .offset(y: -404.5)
            // 요일/날짜 선택 영역
            VStack(spacing: 0) {
                RoutineDaySelector()
                Spacer()
            }
            .frame(width: 393, height: 208)
            .offset(y: -328)
            // 루틴 리스트
            RoutineList()
                .frame(width: 341, height: 209)
                .offset(x: -3, y: -92.5)
            // 루틴 추가 버튼
            RoutineAddButton()
                .frame(width: 111, height: 41)
                .offset(x: 5, y: 285.5)
            // 하단 네비게이션바
            RoutineBottomNavBar()
                .offset(y: 383)
        }
        .frame(width: 393, height: 852)
    }
}

// 상단 상태바 컴포넌트
struct RoutineStatusBar: View {
    var body: some View {
        HStack(spacing: 134) {
            HStack(spacing: 10) {
                Text("9:41")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.black)
            }
            .padding(.leading, 16)
            Rectangle().foregroundColor(.clear).frame(width: 124, height: 10)
            HStack(spacing: 7) {
                RoundedRectangle(cornerRadius: 4.3)
                    .stroke(Color.black, lineWidth: 0.5)
                    .frame(width: 25, height: 13)
                Rectangle()
                    .foregroundColor(.black)
                    .frame(width: 21, height: 9)
                    .cornerRadius(2.5)
            }
            .padding(.trailing, 16)
        }
        .padding(.top, 21)
        .frame(width: 393, height: 43)
        .background(Color.white)
    }
}

// 하단 네비게이션바 컴포넌트
struct RoutineBottomNavBar: View {
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                RoutineNavBarItem(title: "홈", isActive: false)
                RoutineNavBarItem(title: "산책 시작", isActive: false)
                RoutineNavBarItem(title: "루틴 설정", isActive: true, activeColor: Color(red: 0.15, green: 0.75, blue: 0))
                RoutineNavBarItem(title: "산책 기록", isActive: false)
                RoutineNavBarItem(title: "프로필", isActive: false)
            }
            ZStack {
                RoundedRectangle(cornerRadius: 360)
                    .fill(Color.black.opacity(0.1))
                    .frame(width: 120, height: 4)
                    .offset(x: 0.5, y: 6)
            }
            .frame(height: 32)
        }
        .frame(width: 393, height: 86)
        .background(Color.white)
        .overlay(
            Rectangle()
                .inset(by: 0.5)
                .stroke(Color(red: 0.95, green: 0.95, blue: 0.95), lineWidth: 0.5)
        )
    }
}

struct RoutineNavBarItem: View {
    let title: String
    var isActive: Bool = false
    var activeColor: Color = Color(red: 0.62, green: 0.62, blue: 0.62)
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                // 아이콘 영역(추후 이미지 추가)
                Rectangle().foregroundColor(.clear).frame(width: 24, height: 24)
            }
            .frame(height: 24)
            Text(title)
                .font(.custom("Pretendard", size: 12))
                .foregroundColor(isActive ? activeColor : Color(red: 0.62, green: 0.62, blue: 0.62))
                .offset(y: 4)
            Spacer()
        }
        .frame(width: 78, height: 40)
    }
}

// 루틴 추가 버튼 컴포넌트
struct RoutineAddButton: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24.5)
                .fill(Color(red: 0.15, green: 0.75, blue: 0))
                .frame(width: 111, height: 41)
                .shadow(color: Color.black.opacity(0.15), radius: 16, y: 4)
            Text("루틴 추가")
                .font(.custom("Pretendard", size: 15).weight(.semibold))
                .foregroundColor(.white)
                .offset(x: 5.5)
            Text("+")
                .font(.custom("Pretendard", size: 18).weight(.bold))
                .foregroundColor(.white)
                .offset(x: -33.5, y: -1)
        }
    }
}

// 루틴 리스트 컴포넌트
struct RoutineList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            RoutineListItem(title: "아침 산책", time: "오전 8시 30분", isDone: true)
            RoutineListItem(title: "점심 사료주기", time: "알림 없음", isDone: false)
            RoutineListItem(title: "저녁 산책", time: "오후 8시", isDone: false)
        }
        .frame(width: 341, height: 209)
    }
}

struct RoutineListItem: View {
    let title: String
    let time: String
    var isDone: Bool = false
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Ellipse()
                    .stroke(Color(red: 0.15, green: 0.75, blue: 0), lineWidth: 0.5)
                    .background(isDone ? Ellipse().fill(Color(red: 0.15, green: 0.75, blue: 0)) : Ellipse().fill(Color.clear))
                    .frame(width: 22, height: 22)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("Pretendard", size: 17).weight(.semibold))
                    .foregroundColor(isDone ? Color(red: 0.62, green: 0.62, blue: 0.62) : .black)
                    .strikethrough(isDone)
                Text(time)
                    .font(.custom("Pretendard", size: 14))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
            }
        }
    }
}

// 요일/날짜 선택 컴포넌트
struct RoutineDaySelector: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white)
                .frame(width: 393, height: 208)
                .shadow(color: Color.black.opacity(0.06), radius: 30.1, y: 4)
            VStack(spacing: 0) {
                Text("루틴 설정")
                    .font(.custom("Pretendard", size: 20).weight(.semibold))
                    .foregroundColor(.black)
                    .padding(.top, 14)
                HStack(spacing: 11) {
                    ForEach(["월", "화", "수", "목", "금", "토", "일"], id: \.self) { day in
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 29.5)
                                .fill(day == "화" ? Color(red: 0.15, green: 0.75, blue: 0) : Color(red: 0.94, green: 0.94, blue: 0.94))
                                .frame(width: 41, height: 58)
                            Text(day)
                                .font(.custom("Pretendard", size: 12))
                                .foregroundColor(day == "화" ? .white : Color(red: 0.62, green: 0.62, blue: 0.62))
                        }
                    }
                }
                .padding(.top, 20)
            }
        }
    }
}

#Preview {
    RoutineSettingsView()
}

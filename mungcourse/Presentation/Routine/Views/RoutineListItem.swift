import SwiftUI

// 시간 형식 변환 확장
extension String {
    // "08:00" 형식을 "오전 8시" 또는 "오전 8시 30분" 형식으로 변환
    func toKoreanTimeFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let date = formatter.date(from: self) else {
            return self
        }
        
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)
        
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ko_KR")
        
        if minutes == 0 {
            outputFormatter.dateFormat = "a h시"
        } else {
            outputFormatter.dateFormat = "a h시 mm분"
        }
        
        return outputFormatter.string(from: date)
    }
}

// 루틴 리스트 아이템 컴포넌트
struct RoutineListItem: View {
    let routine: Routine
    var onToggle: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    @State private var isToggling = false // 버튼 중복 클릭 방지
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                // 중복 클릭 방지
                guard !isToggling else {
                    print("[RoutineListItem] ⚠️ Toggle button already processing, ignoring tap")
                    return
                }
                
                print("[RoutineListItem] ✅ Toggle button tapped for routine: \(routine.title)")
                isToggling = true
                
                onToggle()
                
                // 1초 후 다시 클릭 가능하도록 설정
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isToggling = false
                }
            }) {
                ZStack {
                    Ellipse()
                        .stroke(Color("main"), lineWidth: 0.5)
                        .background(routine.isDone ? Ellipse().fill(Color("main")) : Ellipse().fill(Color.clear))
                        .frame(width: 22, height: 22)
                    
                    if routine.isDone {
                        Image("icon_check_white")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 17, height: 17)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(routine.title)
                    .font(.custom("Pretendard", size: 17).weight(.semibold))
                    .foregroundColor(routine.isDone ? Color("gray600") : .black)
                    .strikethrough(routine.isDone)
                Text(routine.time.toKoreanTimeFormat())
                    .font(.custom("Pretendard", size: 14))
                    .foregroundColor(routine.isDone ? Color("gray600") : Color(red: 0.5, green: 0.5, blue: 0.5))
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .contentShape(Rectangle())
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("편집", systemImage: "pencil")
            }
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("삭제", systemImage: "trash")
            }
        }
    }
}


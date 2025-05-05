import SwiftUI

// 루틴 리스트 아이템 컴포넌트
struct RoutineListItem: View {
    let routine: Routine
    var onToggle: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                ZStack {
                    Ellipse()
                        .stroke(Color(red: 0.15, green: 0.75, blue: 0), lineWidth: 0.5)
                        .background(routine.isDone ? Ellipse().fill(Color(red: 0.15, green: 0.75, blue: 0)) : Ellipse().fill(Color.clear))
                        .frame(width: 22, height: 22)
                    
                    if routine.isDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(routine.title)
                    .font(.custom("Pretendard", size: 17).weight(.semibold))
                    .foregroundColor(routine.isDone ? Color(red: 0.62, green: 0.62, blue: 0.62) : .black)
                    .strikethrough(routine.isDone)
                Text(routine.time)
                    .font(.custom("Pretendard", size: 14))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
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
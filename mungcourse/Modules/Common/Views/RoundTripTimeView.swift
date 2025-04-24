import SwiftUI

struct RoundTripTimeView: View {
    let timeString: String // "약 30분", "약 1시간" 등의 형식

    var body: some View {
        HStack(spacing: 4) {
            Text("왕복")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor("black10")
            Text(timeString)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor("main")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule() // Capsule 모양 사용 (양쪽 끝이 둥근 형태)
                .fill(Color("pointRed").opacity(0.85)) // 약간 투명한 흰색 배경
        )
        // cornerRadius 13은 Capsule 모양으로 대체합니다.
        // 만약 사각형 모서리 둥글림을 원하시면 Capsule 대신 RoundedRectangle 사용
        // .background(
        //     RoundedRectangle(cornerRadius: 13)
        //         .fill(Color("pointRed").opacity(0.85))
        // )
    }
}

#Preview {
    VStack {
        RoundTripTimeView(timeString: "약 30분")
        RoundTripTimeView(timeString: "약 1시간")
    }
    .padding()
    .background(Color("gray900")) // 배경색을 어둡게 하여 확인 용이
}

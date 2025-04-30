import SwiftUI

// Renamed from ReusableButtonStyleButton
struct MainButton: View {
    let title: String
    let imageName: String // Changed from iconName to imageName
    let backgroundColor: Color
    let foregroundColor: Color // 전경색(텍스트, 아이콘) 파라미터 추가
    let action: () -> Void

    // 기본 foregroundColor("white25")로 설정하는 편의 init 추가
    // Updated init parameter name
    init(title: String, imageName: String, backgroundColor: Color, foregroundColor: Color = Color("white25"), action: @escaping () -> Void) {
        self.title = title
        self.imageName = imageName // Updated property assignment
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) { // 전체 컨테이너, 정렬 기준 설정
                // 배경 및 크기 설정, 테두리 추가
                RoundedRectangle(cornerRadius: 9)
                    .fill(backgroundColor)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 110) // 예시 높이
                    .overlay( // 테두리를 위한 오버레이
                        RoundedRectangle(cornerRadius: 9)
                            // 배경색이 흰색일 때만 #D9D9D9 테두리, 아닐 경우 투명
                            .stroke(backgroundColor == Color("white") ? Color("gray900") : Color.clear, lineWidth: 0.5)
                    )

                // 좌측 상단 텍스트
                Text(title)
                    .font(.headline) // 적절한 폰트 설정
                    .foregroundColor(foregroundColor) // 파라미터로 받은 전경색 사용
                    .padding([.top, .leading], 12) // 내부 패딩
                    .fontWeight(.semibold) // 세미볼드로 변경

                // 우측 하단 아이콘
                HStack { // 아이콘을 우측으로 보내기 위한 HStack
                    Spacer()
                    VStack { // 아이콘을 하단으로 보내기 위한 VStack
                        Spacer()
                        Image(imageName) // Use Image(imageName) instead of Image(systemName:)
                            // .font(.title) // Font modifier might not be needed or behave differently for asset images
                            .resizable() // Make the image resizable
                            .scaledToFit() // Scale image appropriately
                            .frame(width: 48, height: 48) // Adjust frame size as needed for the asset icon
                            .foregroundColor(foregroundColor.opacity(0.8)) // 파라미터로 받은 전경색 사용 (투명도 적용) - SVG면 template 렌더링 모드 필요할 수 있음
                            .padding([.bottom, .trailing], 12) // 내부 패딩
                    }
                }
            }
        }
        .buttonStyle(.plain) // 기본 버튼 스타일 제거하여 커스텀 스타일 적용
    }
}

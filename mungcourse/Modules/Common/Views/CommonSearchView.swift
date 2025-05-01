import SwiftUI

// 가고 싶은 장소를 검색하기 위한 공통 검색 UI 컴포넌트
struct CommonSearchView: View {
    let placeholder: String

    init(placeholder: String = "가고 싶은 장소를 검색하세요") {
        self.placeholder = placeholder
    }
}

extension CommonSearchView {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(placeholder)
                            .font(Font.custom("Pretendard", size: 14))
                            .lineSpacing(21)
                            .foregroundColor(Color(red: 0.62, green: 0.62, blue: 0.62))
                        Spacer()
                        Image("icon_search")
                            .resizable()
                            .frame(width: 22, height: 22)
                    }
                }
            }
            .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
            .cornerRadius(9)
            .frame(width: 353)
        }
        .padding(.horizontal, 20)
    }
}

#if DEBUG
struct CommonSearchView_Previews: PreviewProvider {
    static var previews: some View {
        CommonSearchView()
            .previewLayout(.sizeThatFits)
    }
}
#endif

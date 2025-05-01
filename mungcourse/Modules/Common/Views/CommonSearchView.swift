import SwiftUI

// 가고 싶은 장소를 검색하기 위한 공통 검색 UI 컴포넌트
struct CommonSearchView<TrailingContent: View>: View {
    let placeholder: String
    let trailingContent: () -> TrailingContent

    init(
        placeholder: String = "가고 싶은 장소를 검색하세요",
        @ViewBuilder trailingContent: @escaping () -> TrailingContent
    ) {
        self.placeholder = placeholder
        self.trailingContent = trailingContent
    }
}

// 팡당 검색 아이콘 등 우측 컨텐츠가 없을 때 사용
extension CommonSearchView where TrailingContent == EmptyView {
    init(placeholder: String = "가고 싶은 장소를 검색하세요") {
        self.init(placeholder: placeholder) {
            EmptyView()
        }
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
                        ZStack {
                            trailingContent()
                        }
                        .frame(width: 22, height: 22)
                    }
                }
            }
            .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
            .cornerRadius(9)
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
}

#if DEBUG
struct CommonSearchView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // 기본 검색 필드
            CommonSearchView()

            // 검색 아이콘이 있는 검색 필드
            CommonSearchView {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
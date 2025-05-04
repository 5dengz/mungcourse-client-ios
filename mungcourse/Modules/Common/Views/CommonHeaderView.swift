import SwiftUI

// 새로 만든 공통 헤더 컴포넌트
struct CommonHeaderView<RightContent: View>: View {
    var leftIcon: String?
    var leftAction: (() -> Void)?
    let title: String
    let rightContent: () -> RightContent

    // 기본 생성자: 오른쪽 컨텐츠가 없는 경우 EmptyView 사용
    init(leftIcon: String?,
         leftAction: (() -> Void)? = nil,
         title: String,
         @ViewBuilder rightContent: @escaping () -> RightContent) {
        self.leftIcon = leftIcon
        self.leftAction = leftAction
        self.title = title
        self.rightContent = rightContent
    }
}

// 오른쪽 컨텐츠가 필요 없을 때 사용가능하도록 EmptyView 전용 이니셜라이저 제공
extension CommonHeaderView where RightContent == EmptyView {
    init(leftIcon: String?,
         leftAction: (() -> Void)? = nil,
         title: String) {
        self.init(leftIcon: leftIcon,
                  leftAction: leftAction,
                  title: title) {
            EmptyView()
        }
    }
}

extension CommonHeaderView {
    var body: some View {
        ZStack(alignment: .center) {
            HStack {
                Button(action: { leftAction?() }) {
                    Image(leftIcon ?? "")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                }
                Spacer()
                rightContent()
            }
            .padding(.horizontal, 16)

            Text(title)
                .font(Font.custom("Pretendard-SemiBold", size: 20))
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .allowsHitTesting(false)
        }
        .frame(height: 44)
        .padding(.top, 5)
        .padding(.bottom, 10)
    }
}

#if DEBUG
struct CommonHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 32) {
            CommonHeaderView(leftIcon: "arrow_back", leftAction: {}, title: "테스트")

            CommonHeaderView(leftIcon: "arrow_back", leftAction: {}, title: "프로필") {
                HStack(spacing: 16) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.title2)
                        .foregroundColor(.black)
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
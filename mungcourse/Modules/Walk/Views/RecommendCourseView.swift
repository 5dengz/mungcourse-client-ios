import SwiftUI
import NMapsMap

struct RecommendCourseView: View {
    let onBack: () -> Void
    let onRouteSelected: (RouteOption) -> Void
    let routeOption: RouteOption
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            CommonHeaderView(leftIcon: "arrow_back", leftAction: onBack, title: "AI 코스 추천")
            
            // 지도 뷰
            SimpleNaverMapView(coordinates: routeOption.coordinates)
                .edgesIgnoringSafeArea(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 산책 시작 버튼
            CommonFilledButton(
                title: "산책 시작",
                action: {
                    onRouteSelected(routeOption)
                },
                backgroundColor: Color("main")
            )
            .padding()
            .padding(.top, 12)
        }
        .navigationBarHidden(true)
    }
}

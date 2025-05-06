import SwiftUI
import CoreLocation
import NMapsMap

struct StartWalkTabView: View {
    @EnvironmentObject var dogVM: DogViewModel
    // 추천 코스 흐름 상태
    @State private var showSelectWaypoint: Bool = false
    @State private var showRecommendRoute: Bool = false
    @State private var selectedWaypoints: [DogPlace] = []
    @State private var showStartWalk: Bool = false
    @State private var selectedRouteOption: RouteOption? = nil

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("산책 시작 방식")
                    .font(.custom("Pretendard-SemiBold", size: 18))
                    .padding(.top, 36)
                    .padding(.leading, 29)
                    .padding(.bottom, 15)

                // 직접 산책 시작
                Button(action: {
                    selectedRouteOption = nil
                    showStartWalk = true
                }) {
                    HStack { Text("산책 시작") }
                        .font(.custom("Pretendard-SemiBold", size: 18))
                        .foregroundColor(Color("main"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color("pointwhite"))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color("gray300"), lineWidth: 1))
                }
                .padding(.horizontal, 29)

                CommonFilledButton(title: "코스 선택", action: {
                    showSelectWaypoint = true
                }, backgroundColor: Color("main"), foregroundColor: Color("pointwhite"), cornerRadius: 12)
                .font(.custom("Pretendard-SemiBold", size: 18))
                .padding(.horizontal, 29)

                Spacer()
            }
            .presentationDetents([.height(230)])
            .presentationCornerRadius(20)
            .onDisappear { }
        }
        // 경유지 선택
        .fullScreenCover(isPresented: $showSelectWaypoint) {
            NavigationStack {
                SelectWaypointView(onBack: { showSelectWaypoint = false }, onSelect: { places in
                    selectedWaypoints = places
                    showSelectWaypoint = false
                    showRecommendRoute = true
                })
                .environmentObject(dogVM)
            }
        }
        // 추천 경로 확인
        .fullScreenCover(isPresented: $showRecommendRoute) {
            NavigationStack {
                RecommendCourseView(onBack: { showRecommendRoute = false }, onRouteSelected: { route in
                    selectedRouteOption = route
                    showRecommendRoute = false
                    showStartWalk = true
                }, startLocation: GlobalLocationManager.shared.lastLocation?.coordinate.toNMGLatLng() ?? NMGLatLng(lat: 0, lng: 0), waypoints: selectedWaypoints)
                .environmentObject(dogVM)
            }
        }
        // 산책 시작 화면
        .fullScreenCover(isPresented: $showStartWalk) {
            NavigationStack {
                StartWalkView(routeOption: selectedRouteOption, onForceHome: nil)
                    .environmentObject(dogVM)
            }
        }
    }
}

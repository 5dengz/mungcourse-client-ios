import SwiftUI
import NMapsMap
import Combine

struct RecommendCourseView: View {
    let onBack: () -> Void
    let onRouteSelected: (RouteOption) -> Void
    let startLocation: NMGLatLng
    let waypoints: [DogPlace]
    @StateObject private var viewModel = RecommendCourseViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            CommonHeaderView(leftIcon: "arrow_back", leftAction: onBack, title: "AI 코스 추천")
            
            // 지도 뷰
            SimpleNaverMapView(coordinates: viewModel.recommendedRoute?.coordinates ?? [])
                .edgesIgnoringSafeArea(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 산책 시작 버튼
            CommonFilledButton(
                title: "산책 시작",
                action: {
                    if let route = viewModel.recommendedRoute {
                        onRouteSelected(route)
                    }
                },
                backgroundColor: Color("main")
            )
            .padding()
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.initialize(startLocation: startLocation, waypoints: waypoints)
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("확인"))
            )
        }
    }
}

// RecommendCourseViewModel
class RecommendCourseViewModel: ObservableObject {
    @Published var recommendedRoute: RouteOption? = nil
    
    // 알림 상태
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    private var currentLat: Double = 0
    private var currentLng: Double = 0
    private var cancellables = Set<AnyCancellable>()
    
    // 코스 추천 요청
    func requestRecommendation(startLocation: NMGLatLng, waypoints: [DogPlace]) {
        self.currentLat = startLocation.lat
        self.currentLng = startLocation.lng
        let placeIds = waypoints.map { $0.id }
        WalkService.shared.fetchRecommendRoute(currentLat: currentLat, currentLng: currentLng, dogPlaceIds: placeIds)
            .map { coords, dist, time in
                RouteOption(type: .recommended, totalDistance: dist, estimatedTime: time, waypoints: waypoints, coordinates: coords)
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.showAlertAction(title: "오류", message: error.localizedDescription)
                }
            } receiveValue: { route in
                self.recommendedRoute = route
            }
            .store(in: &cancellables)
    }

    func initialize(startLocation: NMGLatLng, waypoints: [DogPlace]) {
        // API 호출
        requestRecommendation(startLocation: startLocation, waypoints: waypoints)
    }
    
    // 알림 표시
    func showAlertAction(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

// Preview 삭제

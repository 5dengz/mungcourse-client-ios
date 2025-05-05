import SwiftUI
import NMapsMap
import Combine

// AI 추천 경로 API 응답 모델
struct RecommendRouteResponse: Codable {
    let timestamp: String
    let statusCode: Int
    let message: String
    let data: [RecommendRouteData]
    let success: Bool
}

struct RecommendRouteData: Codable {
    let route: [GPSCoordinate]
    let routeLength: Double
    enum CodingKeys: String, CodingKey {
        case route
        case routeLength = "route_length"
    }
}

struct RecommendCourseView: View {
    let onBack: () -> Void
    let startLocation: NMGLatLng
    let waypoints: [DogPlace]
    @EnvironmentObject var dogVM: DogViewModel
    @State private var showStartWalk = false
    @StateObject private var viewModel: RecommendCourseViewModel
    @State private var showRouteWalk = false
    @State private var selectedRoute: RouteOption? = nil

    init(onBack: @escaping () -> Void, startLocation: NMGLatLng, waypoints: [DogPlace]) {
        self.onBack = onBack
        self.startLocation = startLocation
        self.waypoints = waypoints
        self._viewModel = StateObject(wrappedValue: RecommendCourseViewModel(startLocation: startLocation, waypoints: waypoints))
    }

    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            CommonHeaderView(leftIcon: "arrow_back", leftAction: {
                onBack()
            }, title: "AI 코스 추천")
            
            ZStack {
                // 지도 뷰
                AdvancedNaverMapView(
                    dangerCoordinates: $viewModel.dangerCoordinates,
                    centerCoordinate: $viewModel.centerCoordinate,
                    zoomLevel: $viewModel.zoomLevel,
                    pathCoordinates: $viewModel.pathCoordinates,
                    userLocation: $viewModel.userLocation,
                    showUserLocation: true,
                    trackingMode: .normal
                )
                .edgesIgnoringSafeArea(.horizontal)
                
                // 로딩 인디케이터
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            
            // 하단 영역 - 추천 경로 정보 또는 요청 버튼
            VStack(spacing: 16) {
                if viewModel.hasRecommendation {
                    // 추천 경로 정보 표시
                    Text("AI 추천 코스")
                        .font(.custom("Pretendard-Bold", size: 18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("거리")
                                .font(.custom("Pretendard-Regular", size: 12))
                                .foregroundColor(Color.gray)
                            
                            Text(viewModel.formattedDistance)
                                .font(.custom("Pretendard-SemiBold", size: 16))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("예상 시간")
                                .font(.custom("Pretendard-Regular", size: 12))
                                .foregroundColor(Color.gray)
                            
                            Text(viewModel.formattedTime)
                                .font(.custom("Pretendard-SemiBold", size: 16))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.resetRecommendation()
                        }) {
                            Text("다시 추천")
                                .font(.custom("Pretendard-Medium", size: 14))
                                .foregroundColor(Color("main"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color("main"), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    CommonFilledButton(
                        title: "이 코스로 산책하기",
                        action: {
                            if let route = viewModel.recommendedRoute {
                                selectedRoute = route
                                showRouteWalk = true
                            }
                        },
                        backgroundColor: Color("main")
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                } else {
                    // 추천 혹은 자유 산책 옵션
                    Text("원하시는 옵션을 선택하세요")
                        .font(.custom("Pretendard-Bold", size: 18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    HStack(spacing: 12) {
                        CommonFilledButton(
                            title: "코스 추천 받기",
                            action: { viewModel.requestRecommendation() },
                            backgroundColor: Color("main")
                        )
                        MainButton(
                            title: "자유 산책",
                            imageName: "start_walk",
                            backgroundColor: Color("pointwhite"),
                            foregroundColor: Color("main"),
                            action: { showStartWalk = true }
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .padding(.top, 20)
            .background(Color.white)
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .frame(height: viewModel.hasRecommendation ? 190 : 180)
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showRouteWalk) {
            if let route = selectedRoute {
                NavigationStack {
                    RouteWalkView(route: route)
                }
            }
        }
        .fullScreenCover(isPresented: $showStartWalk) {
            NavigationStack {
                StartWalkView()
                    .environmentObject(dogVM)
            }
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
    @Published var isLoading = false
    @Published var centerCoordinate: NMGLatLng
    @Published var userLocation: NMGLatLng?  // 사용자의 현위치 표시용
    @Published var zoomLevel: Double = 15.0
    @Published var pathCoordinates: [NMGLatLng] = []
    @Published var hasRecommendation = false
    @Published var recommendedRoute: RouteOption? = nil
    @Published var dangerCoordinates: [NMGLatLng] = [] // 위험 지역(흡연구역) 좌표 추가
    
    // 요청 파라미터
    private let startLocation: NMGLatLng
    private let waypoints: [DogPlace]
    
    // 알림 상태
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    // 초기화
    init(startLocation: NMGLatLng, waypoints: [DogPlace]) {
        self.startLocation = startLocation
        self.waypoints = waypoints
        // 초기 중심 좌표 및 사용자 위치 설정
        self.centerCoordinate = startLocation
        self.userLocation = startLocation
    }
    
    // 코스 추천 요청 (서버 API 호출)
    func requestRecommendation() {
        isLoading = true
        let lat = startLocation.lat
        let lng = startLocation.lng
        let placeIds = waypoints.map { $0.id }
        let apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? ""
        guard let url = URL(string: "\(apiBaseURL)/v1/walks/recommend") else {
            displayAlert(title: "오류", message: "URL 생성 실패")
            isLoading = false
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["currentLat": lat, "currentLng": lng, "dogPlaceIds": placeIds]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            displayAlert(title: "오류", message: "요청 바디 생성 실패")
            isLoading = false
            return
        }
        NetworkManager.shared.performAPIRequest(request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.displayAlert(title: "오류", message: error.localizedDescription)
                    return
                }
                guard let data = data,
                      let http = response as? HTTPURLResponse,
                      (200...299).contains(http.statusCode) else {
                    self.displayAlert(title: "오류", message: "서버 오류")
                    return
                }
                do {
                    let recommendResponse = try JSONDecoder().decode(RecommendRouteResponse.self, from: data)
                    guard let routeData = recommendResponse.data.first else {
                        self.displayAlert(title: "알림", message: "추천 경로가 없습니다.")
                        return
                    }
                    let coords = routeData.route.map { NMGLatLng(lat: $0.lat, lng: $0.lng) }
                    self.pathCoordinates = coords
                    let distance = routeData.routeLength
                    self.recommendedRoute = RouteOption(type: .recommended,
                                                         totalDistance: distance,
                                                         estimatedTime: 0,
                                                         waypoints: self.waypoints,
                                                         coordinates: coords)
                    self.hasRecommendation = true
                } catch {
                    self.displayAlert(title: "파싱 오류", message: error.localizedDescription)
                }
            }
        }
    }
    
    // 추천 결과 초기화
    func resetRecommendation() {
        hasRecommendation = false
        pathCoordinates = []
        recommendedRoute = nil
    }
    
    // 거리 표시 포맷
    var formattedDistance: String {
        guard let route = recommendedRoute else { return "0.0 km" }
        if route.totalDistance < 1000 {
            return String(format: "%d m", Int(route.totalDistance))
        } else {
            return String(format: "%.1f km", route.totalDistance / 1000)
        }
    }
    
    // 시간 표시 포맷
    var formattedTime: String {
        return "\(recommendedRoute?.estimatedTime ?? 0)분"
    }
    
    // Helper to display alerts
    private func displayAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

#Preview {
    RecommendCourseView(onBack: {}, startLocation: NMGLatLng(lat: 37.5666, lng: 126.9780), waypoints: [])
}
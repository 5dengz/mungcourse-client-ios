import SwiftUI
import NMapsMap
import Combine

struct RecommendCourseView: View {
    let onBack: () -> Void
    @StateObject private var viewModel = RecommendCourseViewModel()
    @State private var showRouteWalk = false
    @State private var selectedRoute: RouteOption? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            CommonHeaderView(leftIcon: "arrow_back", leftAction: {
                onBack()
            }, title: "AI 코스 추천")
            
            ZStack {
                // 지도 뷰
                NaverMapView(
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
                    // 추천 요청 버튼
                    Text("산책로 추천 받기")
                        .font(.custom("Pretendard-Bold", size: 18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    Text("AI가 당신의 위치와 주변 환경을 분석하여 최적의 산책로를 추천해 드립니다.")
                        .font(.custom("Pretendard-Regular", size: 14))
                        .foregroundColor(Color.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    CommonFilledButton(
                        title: "코스 추천 받기",
                        action: {
                            viewModel.requestRecommendation()
                        },
                        backgroundColor: Color("main")
                    )
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
        .onAppear {
            // 위치 업데이트 시작
            viewModel.startUpdatingLocation()
        }
        .fullScreenCover(isPresented: $showRouteWalk) {
            if let route = selectedRoute {
                NavigationStack {
                    RouteWalkView(route: route)
                }
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
    @Published var centerCoordinate = NMGLatLng(lat: 37.5666, lng: 126.9780) // 기본 서울 좌표
    @Published var zoomLevel: Double = 15.0
    @Published var userLocation: NMGLatLng? = nil
    @Published var pathCoordinates: [NMGLatLng] = []
    @Published var hasRecommendation = false
    @Published var recommendedRoute: RouteOption? = nil
    
    // 알림 상태
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    // 위치 업데이트 시작
    func startUpdatingLocation() {
        GlobalLocationManager.shared.startUpdatingLocation()
        GlobalLocationManager.shared.$lastLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                guard let self = self else { return }
                let coord = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
                self.userLocation = coord
                
                // 초기에는 사용자 위치로 지도 중심 이동
                if self.centerCoordinate.lat == 37.5666 && self.centerCoordinate.lng == 126.9780 {
                    self.centerCoordinate = coord
                }
            }
            .store(in: &cancellables)
    }
    
    // 코스 추천 요청
    func requestRecommendation() {
        guard let userLocation = userLocation else {
            showAlert(title: "위치 오류", message: "현재 위치를 가져올 수 없습니다. 위치 서비스가 활성화되어 있는지 확인해주세요.")
            return
        }
        
        isLoading = true
        
        // API 호출 시뮬레이션 (실제로는 서버에 요청)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            
            // 임시 경로 생성 (실제로는 API 응답에서 받은 경로)
            let coordinates = self.generateRandomPath(around: userLocation, pointCount: 8, radiusKm: 0.5)
            self.pathCoordinates = coordinates
            
            // 추천 경로 생성
            let totalDistance = self.calculateTotalDistance(coordinates)
            let estimatedTime = self.calculateEstimatedTime(totalDistance)
            
            self.recommendedRoute = RouteOption(
                type: .recommended,
                totalDistance: totalDistance,
                estimatedTime: estimatedTime,
                waypoints: [],
                coordinates: coordinates
            )
            
            self.hasRecommendation = true
            self.isLoading = false
            
            // 지도 중심과 줌 레벨 조정
            self.adjustMapView(for: coordinates)
        }
    }
    
    // 추천 결과 초기화
    func resetRecommendation() {
        hasRecommendation = false
        pathCoordinates = []
        recommendedRoute = nil
    }
    
    // 형식화된 거리
    var formattedDistance: String {
        guard let route = recommendedRoute else { return "0.0 km" }
        return String(format: "%.1f km", route.totalDistance / 1000.0)
    }
    
    // 형식화된 시간
    var formattedTime: String {
        guard let route = recommendedRoute else { return "0분" }
        let minutes = route.estimatedTime
        if minutes < 60 {
            return "\(minutes)분"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(hours)시간 \(mins)분"
        }
    }
    
    // 임의의 경로 생성 (테스트용)
    private func generateRandomPath(around center: NMGLatLng, pointCount: Int, radiusKm: Double) -> [NMGLatLng] {
        var path: [NMGLatLng] = [center]
        
        for _ in 1..<pointCount {
            // 이전 포인트를 기준으로 랜덤한 방향으로 이동
            let lastPoint = path.last!
            
            // 랜덤한 방향 (0-359도)
            let angle = Double.random(in: 0..<360) * .pi / 180
            
            // 최대 반경 내에서 랜덤한 거리
            let distance = Double.random(in: 0.05...0.1) * radiusKm
            
            // 지구 반경 (km)
            let earthRadius = 6371.0
            
            // 위도/경도 변화량 계산
            let latChange = distance / earthRadius * (.pi / 180) * cos(angle)
            let lngChange = distance / earthRadius * (.pi / 180) * sin(angle) / cos(lastPoint.lat * .pi / 180)
            
            let newLat = lastPoint.lat + latChange * 180 / .pi
            let newLng = lastPoint.lng + lngChange * 180 / .pi
            
            path.append(NMGLatLng(lat: newLat, lng: newLng))
        }
        
        // 마지막에 시작점으로 돌아오는 경로 추가 (원형 경로)
        path.append(center)
        
        return path
    }
    
    // 총 거리 계산 (미터 단위)
    private func calculateTotalDistance(_ coordinates: [NMGLatLng]) -> Double {
        var totalDistance = 0.0
        
        for i in 0..<coordinates.count-1 {
            let point1 = coordinates[i]
            let point2 = coordinates[i+1]
            
            // 하버사인 공식을 사용하여 두 지점 간 거리 계산
            let lat1 = point1.lat * .pi / 180
            let lat2 = point2.lat * .pi / 180
            let dLat = lat2 - lat1
            let dLon = (point2.lng - point1.lng) * .pi / 180
            
            let a = pow(sin(dLat/2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon/2), 2)
            let c = 2 * atan2(sqrt(a), sqrt(1-a))
            
            // 지구 반경 (미터)
            let earthRadius = 6371000.0
            let distance = earthRadius * c
            
            totalDistance += distance
        }
        
        return totalDistance
    }
    
    // 예상 시간 계산 (분 단위, 평균 속도 4km/h 가정)
    private func calculateEstimatedTime(_ distanceInMeters: Double) -> Int {
        // 분당 약 67미터 (4km/h)
        let metersPerMinute = 4000.0 / 60.0
        let minutes = Int(distanceInMeters / metersPerMinute)
        return max(1, minutes)
    }
    
    // 지도 뷰 조정
    private func adjustMapView(for coordinates: [NMGLatLng]) {
        // 경로의 중심점 계산
        var sumLat = 0.0
        var sumLng = 0.0
        
        for coord in coordinates {
            sumLat += coord.lat
            sumLng += coord.lng
        }
        
        centerCoordinate = NMGLatLng(
            lat: sumLat / Double(coordinates.count),
            lng: sumLng / Double(coordinates.count)
        )
        
        // 경로에 맞게 줌 레벨 조정
        // (실제 구현에서는 경로의 경계 상자를 계산하여 최적의 줌 레벨 설정)
        zoomLevel = 15.0
    }
    
    // 알림 표시
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

#Preview {
    RecommendCourseView(onBack: {})
} 
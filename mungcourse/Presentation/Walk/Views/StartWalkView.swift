import SwiftUI
import NMapsMap
import Foundation

// MARK: - 디버그 로그 핸들러
struct LogHandler {
    // 일반 로그
    static func log(_ message: String) {
        print("🧭 [StartWalkView] \(message)")
    }
    
    // 사용자 위치 로그
    static func logUserLocation(_ location: NMGLatLng?) {
        let locationText = location?.description ?? "nil"
        log("위치: \(locationText)")
    }
    
    // 상태 변경 로그
    static func logStateChange(type: String, from: Any, to: Any) {
        log("\(type) 변경: \(from) → \(to)")
    }
    
    // 상태 확인 로그
    static func logState(title: String, vm: StartWalkViewModel) {
        log("\(title):")
        log("  - smokingZones: \(vm.smokingZones.count)개")
        log("  - dogPlaces: \(vm.dogPlaces.count)개")
        log("  - userLocation: \(vm.userLocation?.description ?? "nil")")
    }
}

// MARK: - 네이버 맵 뷰 래퍼
struct NaverMapWrapper: View {
    @ObservedObject var viewModel: StartWalkViewModel
    // 추천 경로 시 경유지 좌표 전달
    var routeWaypoints: [NMGLatLng]? = nil
    // 프리뷰 경로 전달
    var plannedPathCoordinates: [NMGLatLng]? = nil
    
    var body: some View {
        AdvancedNaverMapView(
            dangerCoordinates: $viewModel.smokingZones,
            // 경유지가 있는 경우에만 dogPlaceCoordinates 전달, 아니면 빈 배열
            dogPlaceCoordinates: routeWaypoints ?? [],
            centerCoordinate: $viewModel.centerCoordinate,
            zoomLevel: $viewModel.zoomLevel,
            // AI 경로가 있으면 그것을 표시, 없으면 실시간 경로 표시
            pathCoordinates: plannedPathCoordinates != nil ? .constant(plannedPathCoordinates!) : $viewModel.pathCoordinates,
            userLocation: $viewModel.userLocation,
            showUserLocation: true,
            trackingMode: .direction
        )
        .onAppear { 
            LogHandler.log("NaverMapView appear") 
        }
        .onChange(of: viewModel.centerCoordinate) { oldCoord, newCoord in
            LogHandler.log("중심좌표 변경: (\(oldCoord.lat), \(oldCoord.lng)) → (\(newCoord.lat), \(newCoord.lng))")
        }
        .onChange(of: viewModel.userLocation) { oldLocation, newLocation in
            if let location = newLocation {
                LogHandler.log("사용자위치 변경: (\(location.lat), \(location.lng))")
            } else {
                LogHandler.log("사용자위치 변경: nil")
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - 상태 감시 컴포넌트
struct StateObserver: View {
    @ObservedObject var viewModel: StartWalkViewModel
    
    var body: some View {
        Color.clear
            .onAppear {
                LogHandler.log("onAppear")
                LogHandler.log("초기 상태: smokingZones=\(viewModel.smokingZones.count)개, dogPlaces=\(viewModel.dogPlaces.count)개")
                LogHandler.logUserLocation(viewModel.userLocation)
            }
            .onChange(of: viewModel.isWalking) { oldValue, newValue in
                LogHandler.log("산책상태 변경: \(oldValue) → \(newValue)")
            }
            .onChange(of: viewModel.pathCoordinates.count) { oldCount, newCount in
                LogHandler.log("경로좌표 개수 변경: \(oldCount) → \(newCount)")
            }
            .onChange(of: viewModel.smokingZones.count) { oldCount, newCount in
                LogHandler.log("흡연구역 개수 변경: \(oldCount) → \(newCount)")
            }
            .onChange(of: viewModel.dogPlaces.count) { oldCount, newCount in
                LogHandler.log("반려견장소 개수 변경: \(oldCount) → \(newCount)")
            }
    }
}

// MARK: - 메인 뷰
struct StartWalkView: View {
    // MARK: - 프로퍼티
    let routeOption: RouteOption?
    var onForceHome: (() -> Void)? = nil
    
    @StateObject private var viewModel = StartWalkViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dogVM: DogViewModel
    
    @State private var showCompleteAlert = false
    @State private var completedSession: WalkSession? = nil
    @State private var isCompleteActive = false
    @State private var effectScale: CGFloat = 0.5
    @State private var effectOpacity: Double = 1.0
    @State private var didInitRoute: Bool = false
    
    // MARK: - 헬퍼 메서드
    private func useRouteOptionIfNeeded() {
        guard !didInitRoute, let route = routeOption else { return }
        LogHandler.log("추천 경로 사용: \(route.coordinates.count)개 좌표, \(route.totalDistance)m")
        // 중심 좌표 설정
        viewModel.centerCoordinate = route.coordinates.first ?? NMGLatLng(lat: 37.5665, lng: 126.9780)
        viewModel.zoomLevel = 15.0
        didInitRoute = true
        
        // 디버그 로그
        LogHandler.log("프리뷰 경로 좌표 개수: \(route.coordinates.count)")
    }
    
    private func logStatusAfterDelay() {
        LogHandler.log("초기 API 로드 확인")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            LogHandler.logState(title: "1초 후 상태", vm: viewModel)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            LogHandler.logState(title: "5초 후 상태", vm: viewModel)
        }
    }
    
    // MARK: - 바디
    var body: some View {
        ZStack(alignment: .bottom) {
            // 상태 관찰 컴포넌트
            StateObserver(viewModel: viewModel)
            
            // 메인 콘텐츠
            VStack(spacing: 0) {
                // 맵 뷰 영역
                NaverMapWrapper(
                    viewModel: viewModel,
                    // 바로 시작하기면 dogPlaces, 추천경로면 기존대로
                    routeWaypoints: {
                        if routeOption == nil {
                            return viewModel.dogPlaces.map { NMGLatLng(lat: $0.lat, lng: $0.lng) }
                        } else {
                            return (routeOption?.waypoints.isEmpty ?? true) ? [] : routeOption?.waypoints.map { NMGLatLng(lat: $0.lat, lng: $0.lng) }
                        }
                    }(),
                    // AI 추천 경로는 반드시 plannedPathCoordinates로 전달
                    plannedPathCoordinates: {
                        // 좌표 로그 출력
                        if let coordinates = routeOption?.coordinates {
                            LogHandler.log("plannedPathCoordinates 좌표 목록:")
                            for (index, coord) in coordinates.enumerated() {
                                LogHandler.log("  [\(index)] lat: \(coord.lat), lng: \(coord.lng)")
                            }
                            LogHandler.log("총 \(coordinates.count)개의 좌표 확인")
                        } else {
                            LogHandler.log("plannedPathCoordinates가 nil입니다")
                        }
                        return routeOption?.coordinates
                    }()
                )
            }
            
            // 하단 컨트롤러
            StartWalkBottomView(
                viewModel: viewModel,
                completedSession: $completedSession,
                isCompleteActive: $isCompleteActive,
                onForceHome: onForceHome
            )
            .environmentObject(dogVM)
            .onAppear {
                LogHandler.log("BottomView appear")
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationBarHidden(true)
        .overlay(
            WalkHeaderView(onBack: { dismiss() }),
            alignment: .top
        )
        .alert("위치 권한 필요", isPresented: $viewModel.showPermissionAlert) {
            Button("설정으로 이동") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("산책을 시작하려면 위치 권한이 필요합니다.\n설정에서 위치 권한을 허용해주세요.")
        }
        .alert("위치 서비스 에러", isPresented: $viewModel.showLocationErrorAlert) {
            Button("확인") {}
        } message: {
            Text(viewModel.locationErrorMessage)
        }
        .onAppear {
            // 경로 옵션 적용
            useRouteOptionIfNeeded()
            // 앱 실행 시 바로 산책 시작하여 위치 추적을 활성화
            viewModel.startWalk()
            
            // 경로 사용 디버그 로그
            if let route = routeOption {
                LogHandler.log("경로 옵션 확인: \(route.coordinates.count)개 좌표, \(route.totalDistance)m")
            }
        }
        .task {
            logStatusAfterDelay()
        }
    }
}

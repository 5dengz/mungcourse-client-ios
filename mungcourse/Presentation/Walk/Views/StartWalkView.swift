import SwiftUI
import NMapsMap
import Foundation

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
        .edgesIgnoringSafeArea(.all)
    }
}



// MARK: - 메인 뷰
struct StartWalkView: View {
    // MARK: - 프로퍼티
    let routeOption: RouteOption?
    var onForceHome: (() -> Void)? = nil
    
    // 하나의 바인딩을 동시에 false로 만들어 네비게이션 스택을 지우기 위해 사용
    @Environment(\.presentationMode) var presentationMode
    
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
        // 중심 좌표 설정
        viewModel.centerCoordinate = route.coordinates.first ?? NMGLatLng(lat: 37.5665, lng: 126.9780)
        viewModel.zoomLevel = 15.0
        didInitRoute = true
    }
    

    
    // MARK: - 바디
    var body: some View {
        ZStack(alignment: .bottom) {
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
                    plannedPathCoordinates: routeOption?.coordinates
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
            
            // 산책 완료 화면 네비게이션
            let walkCompleteLink = NavigationLink(
                destination: WalkCompleteView(
                    walkData: completedSession, // completedSession 자체를 전달
                    onForceDismiss: onForceHome // onForceHome 콜백을 WalkCompleteView에 전달
                ),
                isActive: $isCompleteActive
            ) {
                EmptyView()
            }
        }
        .onChange(of: isCompleteActive) { active in
            if active {
                // 산책 완료 화면으로 이동할 때
                // 지도와 관련된 모든 데이터 소거
                viewModel.clearMapResources()
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
            
            // 산책 완료 화면에서 홈 버튼 클릭 시 dismissAllScreens 알림 수신을 위한 옵저버 추가
            let observer = NotificationCenter.default.addObserver(
                forName: .dismissAllScreens,
                object: nil,
                queue: .main
            ) { _ in
                print("🔥 [StartWalkView] 화면 해제 알림 수신")
                dismiss()
            }
            
            // 메모리 누수 방지를 위해 onDisappear에서 옵저버 제거
            NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main) { _ in
                NotificationCenter.default.removeObserver(observer)
            }
        }

    }
}

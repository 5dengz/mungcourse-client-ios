import SwiftUI
import NMapsMap
// Common 모듈에서 가져옴
import Foundation

struct StartWalkView: View {
    let routeOption: RouteOption?
    var onForceHome: (() -> Void)? = nil
    @StateObject private var viewModel = StartWalkViewModel()

    @Environment(\.dismiss) private var dismiss
    @State private var showCompleteAlert = false
    @State private var completedSession: WalkSession? = nil
    @State private var isCompleteActive = false // WalkCompleteView로 이동 네비게이션링크 State
    @State private var effectScale: CGFloat = 0.5
    @State private var effectOpacity: Double = 1.0
    @EnvironmentObject var dogVM: DogViewModel // 강아지 뷰모델 주입
    @State private var didInitRoute: Bool = false
    
    // 추천 경로가 있으면 pathCoordinates, centerCoordinate 등 초기화
    private func useRouteOptionIfNeeded() {
        guard !didInitRoute, let route = routeOption else { return }
        viewModel.pathCoordinates = route.coordinates
        viewModel.centerCoordinate = route.coordinates.first ?? NMGLatLng(lat: 37.5665, lng: 126.9780)
        viewModel.zoomLevel = 15.0
        didInitRoute = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Debug: view appear
            Color.clear
            .onAppear {
                print("[디버그] StartWalkView onAppear")
                useRouteOptionIfNeeded()
            }
            .onChange(of: viewModel.isWalking) { newValue, oldValue in
                print("[디버그] isWalking changed: \(newValue)")
            }
            .onChange(of: viewModel.pathCoordinates) { newPath, oldPath in
                print("[디버그] StartWalkView pathCoordinates: \(newPath)")
            }
            // Content area
            VStack(spacing: 0) {
                // Map View
                ZStack {
                    AdvancedNaverMapView(
                        dangerCoordinates: $viewModel.smokingZones,
                        dogPlaceCoordinates: viewModel.dogPlaces.map { NMGLatLng(lat: $0.lat, lng: $0.lng) },
                        centerCoordinate: $viewModel.centerCoordinate,
                        zoomLevel: $viewModel.zoomLevel,
                        pathCoordinates: $viewModel.pathCoordinates,
                        userLocation: $viewModel.userLocation,
                        showUserLocation: true, // 무조건 true로 고정
                        trackingMode: .direction
                    )
                    .onAppear { print("[디버그] NaverMapView appear in StartWalkView") }
                    .onChange(of: viewModel.centerCoordinate) { newCoord, oldCoord in
                        print("[디버그] viewModel.centerCoordinate: \(newCoord)")
                    }
                    .edgesIgnoringSafeArea(.all)
                }
            }
            // Bottom controller panel (분리된 서브뷰)
            StartWalkBottomView(
                viewModel: viewModel,
                completedSession: $completedSession,
                isCompleteActive: $isCompleteActive,
                onForceHome: onForceHome
            )
            .environmentObject(dogVM)
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
    }
}


// RoundedCorner 구조체와 View extension은 Common/Utils/CommonViewExtensions.swift 로 이동했습니다.
// 사용하려면 해당 파일이 프로젝트에 포함되어 있어야 합니다.

import SwiftUI
import NMapsMap
// Common 모듈에서 가져옴
import Foundation

struct StartWalkView: View {
    let routeOption: RouteOption?
    @StateObject private var viewModel = StartWalkViewModel()

    @Environment(\.dismiss) private var dismiss
    @State private var showCompleteAlert = false
    @State private var completedSession: WalkSession? = nil
    @State private var isCompleteActive = false // WalkCompleteView로 이동 네비게이션링크 State
    @State private var effectScale: CGFloat = 0.5
    @State private var effectOpacity: Double = 1.0
    @EnvironmentObject var dogVM: DogViewModel // 강아지 뷰모델 주입
    @State private var didInitRoute: Bool = false
    
    var body: some View {
        // 추천 경로가 있으면 초기화
        useRouteOptionIfNeeded()

        ZStack(alignment: .bottom) {
            // Debug: view appear
            Color.clear
                .onAppear { print("[디버그] StartWalkView onAppear") }
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
                        trackingMode: .normal
                    )
                    .onAppear { print("[디버그] NaverMapView appear in StartWalkView") }
                    .onChange(of: viewModel.centerCoordinate) { newCoord, oldCoord in
                        print("[디버그] viewModel.centerCoordinate: \(newCoord)")
                    }
                    .edgesIgnoringSafeArea(.all)
                }
            }
            // Bottom controller panel
            WalkControllerView(
                distance: viewModel.formattedDistance,
                duration: viewModel.formattedDuration,
                calories: viewModel.formattedCalories,
                state: viewModel.isPaused ? .paused : (viewModel.isWalking ? .active : .notStarted),
                onStart: {
                    print("[디버그] WalkControllerView onStart pressed")
                    viewModel.startWalk()
                },
                onPause: {
                    print("[디버그] WalkControllerView onPause pressed")
                    viewModel.pauseWalk()
                },
                onResume: {
                    print("[디버그] WalkControllerView onResume pressed")
                    viewModel.resumeWalk()
                },
                onEnd: {
                    print("[디버그] WalkControllerView onEnd pressed")
                    completedSession = viewModel.endWalk()
                    if let session = completedSession {
                        // 메인 강아지 id 자동 fetch
                        fetchMainDogId { mainDogId in
                            let dogIds = mainDogId != nil ? [mainDogId!] : []
                            viewModel.uploadWalkSession(session, dogIds: dogIds) { success in
                                if success {
                                    print("✅ 산책 데이터 업로드 성공")
                                    isCompleteActive = true
                                } else {
                                    print("❌ 산책 데이터 업로드 실패")
                                    isCompleteActive = true
                                }
                            }
                        }
                    }
                }
            )
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationBarHidden(true)
        .overlay(
            WalkHeaderView(onBack: { dismiss() }),
            alignment: .top
        )
        // 산책 완료 화면 네비게이션
        NavigationLink(
            destination: {
                if let session = completedSession {
                    let walkData = WalkSessionData(
                        distance: session.distance,
                        duration: Int(session.duration),
                        date: session.endTime,
                        coordinates: session.path
                    )
                    WalkCompleteView(walkData: walkData)
                } else {
                    EmptyView()
                }
            }(),
            isActive: $isCompleteActive
        ) {
            EmptyView()
        }
        .hidden()
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

#Preview {
    NavigationStack {
        StartWalkView()
            .environmentObject(DogViewModel())
    }
}

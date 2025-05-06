import SwiftUI
import NMapsMap
import Combine

struct SelectWaypointView: View {
    let onBack: () -> Void
    let onFinish: (RouteOption) -> Void
    @StateObject private var viewModel = SelectWaypointViewModel()
    @State private var showRouteSelection = false // RecommendCourseView 표시 토글
    @State private var selectedWaypoints: [DogPlace] = []
    @State private var routeOption: RouteOption? = nil
    @State private var isLoadingRecommendation = false
    @State private var cancellables = Set<AnyCancellable>()  // Combine 구독 저장소
    @EnvironmentObject var dogVM: DogViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CommonHeaderView(leftIcon: "arrow_back", leftAction: {
                    onBack()
                }, title: "경유지 선택")
                
                // 검색 입력 필드
                HStack {
                    TextField("가고 싶은 장소를 검색하세요", text: $viewModel.searchText)
                        .font(Font.custom("Pretendard-SemiBold", size: 15))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.clearSearch()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    } else {
                        Image("icon_search")
                            .resizable()
                            .frame(width: 22, height: 22)
                    }
                }
                .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                .cornerRadius(9)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                    Spacer()
                } else {
                    // 검색 결과 목록
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if viewModel.dogPlaces.isEmpty && !viewModel.searchText.isEmpty {
                                EmptyResultView()
                            } else {
                                ForEach(viewModel.dogPlaces) { place in
                                    DogPlaceResultRow(place: place, isSelected: viewModel.isSelected(place.id), onSelect: {
                                        viewModel.toggleSelection(for: place.id)
                                    })
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        .padding(.vertical, 12)
                    }
                    
                    // 선택 완료 버튼: API 호출
                    CommonFilledButton(
                        title: "선택 완료",
                        action: {
                            let places = viewModel.getSelectedPlaces()
                            let current = viewModel.getCurrentLocation()?.toNMGLatLng() ?? NMGLatLng(lat: 37.5666, lng: 126.9780)
                            isLoadingRecommendation = true
                            Task {
                                do {
                                    let result: (coordinates: [NMGLatLng], totalDistance: Double, estimatedTime: Int) = try await withCheckedThrowingContinuation { continuation in
                                        var cancellable: AnyCancellable?
                                        cancellable = WalkService.shared.fetchRecommendRoute(currentLat: current.lat, currentLng: current.lng, dogPlaceIds: places.map { $0.id })
                                            .sink { completion in
                                                if case .failure(let error) = completion {
                                                    continuation.resume(throwing: error)
                                                }
                                                cancellable?.cancel()
                                            } receiveValue: { output in
                                                continuation.resume(returning: output)
                                                cancellable?.cancel()
                                            }
                                    }
                                    let (coords, dist, time) = result
                                    let route = RouteOption(type: .recommended, totalDistance: dist, estimatedTime: time, waypoints: places, coordinates: coords)
                                    routeOption = route
                                    showRouteSelection = true
                                } catch {
                                    viewModel.errorMessage = error.localizedDescription
                                }
                                isLoadingRecommendation = false
                            }
                        },
                        isEnabled: viewModel.isCompleteButtonEnabled && !isLoadingRecommendation,
                        backgroundColor: Color("main")
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            if isLoadingRecommendation {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView("코스 생성 중...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // 화면이 나타날 때 위치 업데이트 시작
            GlobalLocationManager.shared.startUpdatingLocation()
        }
        .fullScreenCover(isPresented: $showRouteSelection) {
            if let route = routeOption {
                NavigationStack {
                    RoutePreviewView(
                        coordinates: route.coordinates,
                        distance: route.totalDistance,
                        estimatedTime: route.estimatedTime,
                        waypoints: route.waypoints,
                        onForceHome: { showRouteSelection = false }
                    )
                    .environmentObject(dogVM)
                }
            }
        }
    }
}

// 검색 결과 행 컴포넌트
struct DogPlaceResultRow: View {
    let place: DogPlace
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // 왼쪽 아이콘
            Image("icon_search")
                .resizable()
                .frame(width: 22, height: 22)
            
            // 장소명
            Text(place.name)
                .font(Font.custom("Pretendard-Regular", size: 16))
                .foregroundColor(.black)
            
            Spacer()
            
            // 선택 버튼
            Button(action: onSelect) {
                ZStack {
                    Circle()
                        .stroke(Color("main"), lineWidth: 1)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Circle()
                            .fill(Color("main"))
                            .frame(width: 22, height: 22)
                        
                        Image("icon_check")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 22, height: 22)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(16)
    }
}

// 검색 결과가 없을 때 보여줄 뷰
struct EmptyResultView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "magnifyingglass")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(Color("gray400"))
                .padding(.top, 40)
            
            Text("검색어와 일치하는 장소가 없습니다")
                .font(Font.custom("Pretendard-Regular", size: 16))
                .foregroundColor(Color("gray600"))
            
            Text("다른 검색어로 시도해보세요")
                .font(Font.custom("Pretendard-Regular", size: 14))
                .foregroundColor(Color("gray400"))
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
}

// CLLocationCoordinate2D → NMGLatLng 변환 확장
import NMapsMap
import CoreLocation

extension CLLocationCoordinate2D {
    func toNMGLatLng() -> NMGLatLng {
        NMGLatLng(lat: self.latitude, lng: self.longitude)
    }
}
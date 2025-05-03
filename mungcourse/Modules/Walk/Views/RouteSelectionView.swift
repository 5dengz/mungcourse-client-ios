import SwiftUI
import NMapsMap

struct RouteSelectionView: View {
    let onBack: () -> Void
    let onSelectRoute: (RouteOption) -> Void
    
    @StateObject private var viewModel: RouteSelectionViewModel
    @State private var showRouteWalkView = false
    @State private var selectedRoute: RouteOption? = nil
    
    init(startLocation: CLLocationCoordinate2D, waypoints: [DogPlace], onBack: @escaping () -> Void, onSelectRoute: @escaping (RouteOption) -> Void) {
        self.onBack = onBack
        self.onSelectRoute = onSelectRoute
        _viewModel = StateObject(wrappedValue: RouteSelectionViewModel(startLocation: startLocation, waypoints: waypoints))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CommonHeaderView(leftIcon: "arrow_back", leftAction: {
                onBack()
            }, title: "추천 경로")
            
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
            
            // 경로 옵션 목록
            VStack(spacing: 16) {
                Text("추천 경로")
                    .font(.custom("Pretendard-Bold", size: 18))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // 경로 옵션 카드 목록
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Array(viewModel.routeOptions.enumerated()), id: \.element.id) { index, route in
                            RouteOptionCard(
                                route: route,
                                isSelected: viewModel.selectedRouteIndex == index,
                                onSelect: {
                                    viewModel.selectRoute(at: index)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: 160)
                
                Spacer()
                
                // 선택 완료 버튼
                if let selectedIndex = viewModel.selectedRouteIndex, selectedIndex < viewModel.routeOptions.count {
                    CommonFilledButton(
                        title: "이 경로로 산책하기",
                        action: {
                            selectedRoute = viewModel.routeOptions[selectedIndex]
                            onSelectRoute(viewModel.routeOptions[selectedIndex])
                            showRouteWalkView = true
                        },
                        backgroundColor: Color("main")
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(Color.white)
            .cornerRadius(20, corners: [.topLeft, .topRight])
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showRouteWalkView) {
            if let route = selectedRoute {
                NavigationStack {
                    RouteWalkView(route: route)
                }
            }
        }
    }
}

// 경로 옵션 카드 뷰
struct RouteOptionCard: View {
    let route: RouteOption
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // 경로 타입 아이콘
                Image(systemName: iconForRouteType(route.type))
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Color.white : Color("main"))
                
                Text(route.type.title)
                    .font(.custom("Pretendard-Bold", size: 16))
                    .foregroundColor(isSelected ? .white : .black)
                
                Spacer()
            }
            
            Text(route.type.description)
                .font(.custom("Pretendard-Regular", size: 12))
                .foregroundColor(isSelected ? .white.opacity(0.9) : Color.gray)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("거리")
                        .font(.custom("Pretendard-Regular", size: 12))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : Color.gray)
                    
                    Text(route.formattedDistance)
                        .font(.custom("Pretendard-SemiBold", size: 16))
                        .foregroundColor(isSelected ? .white : .black)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("예상 시간")
                        .font(.custom("Pretendard-Regular", size: 12))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : Color.gray)
                    
                    Text(route.formattedTime)
                        .font(.custom("Pretendard-SemiBold", size: 16))
                        .foregroundColor(isSelected ? .white : .black)
                }
            }
        }
        .padding(16)
        .frame(width: 220, height: 140)
        .background(isSelected ? Color("main") : Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
        )
        .onTapGesture {
            onSelect()
        }
    }
    
    private func iconForRouteType(_ type: RouteType) -> String {
        switch type {
        case .recommended:
            return "star.fill"
        case .shortest:
            return "bolt.fill"
        case .scenic:
            return "leaf.fill"
        case .custom:
            return "pencil"
        }
    }
}

#Preview {
    let dogPlace = DogPlace(
        id: 1,
        name: "애견카페 멍카페",
        dogPlaceImgUrl: nil,
        distance: 1200,
        category: "cafe",
        openingHours: "09:00 ~ 21:00",
        lat: 37.5666103,
        lng: 126.9783882
    )
    
    return RouteSelectionView(
        startLocation: CLLocationCoordinate2D(latitude: 37.5642135, longitude: 127.0016985),
        waypoints: [dogPlace],
        onBack: {},
        onSelectRoute: { _ in }
    )
} 
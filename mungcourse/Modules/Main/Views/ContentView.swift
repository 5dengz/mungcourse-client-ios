//
//  ContentView.swift
//  mungcourse
//
//  Created by Kyoungho Eom on 4/6/25.
//

import SwiftUI
import Combine
import NMapsMap

struct ContentView: View {
    enum Tab: Int, CaseIterable {
        case home, startWalk, routine, history, profile
        var title: String {
            switch self {
            case .home: return "홈"
            case .startWalk: return "코스 선택"
            case .routine: return "루틴 설정"
            case .history: return "산책 기록"
            case .profile: return "프로필"
            }
        }
        var icon: String {
            switch self {
            case .home: return "tab_home"
            case .startWalk: return "tab_map"
            case .routine: return "tab_route"
            case .history: return "tab_history"
            case .profile: return "tab_profile"
            }
        }
    }

    @State private var selectedTab: Tab = .home
    @State private var showSelectWaypoint = false  // 경유지 선택 및 추천 흐름은 SelectWaypointView 내에서 처리
    @State private var showStartWalk = false
    @State private var showingDogSelection = false
    @State private var showWalkDogSelection = false // 산책용 강아지 선택 화면
    enum WalkStartType { case direct, recommend }
    @State private var walkStartType: WalkStartType = .direct
    @EnvironmentObject var dogVM: DogViewModel
    @State private var userLocation: NMGLatLng? = nil
    @State private var selectedRouteOption: RouteOption? = nil
    @State private var cancellables = Set<AnyCancellable>()

    private let imageHeight: CGFloat = 24
    private let imageToBorder: CGFloat = 10
    private let imageToText: CGFloat = 3
    private let textToSafeArea: CGFloat = 1
    private let tabFontSize: CGFloat = 12
    private var tabBarHeight: CGFloat {
        imageToBorder + imageHeight + imageToText + tabFontSize + textToSafeArea
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView(
                        selectedTab: $selectedTab
                    )
                    .environmentObject(dogVM)
                case .startWalk:
                    HomeView(
                        selectedTab: $selectedTab
                    )
                    .environmentObject(dogVM)
                case .routine:
                    RoutineSettingsView()
                case .history:
                    WalkHistoryView()
                case .profile:
                    ProfileTabView()
                }
            }

            VStack(spacing: 0) {
                Spacer()
                HStack {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Button(action: {
                            if tab == .startWalk {
                                showSelectWaypoint = true
                            } else {
                                selectedTab = tab
                            }
                        }) {
                            VStack(spacing: 0) {
                                Spacer().frame(height: imageToBorder)
                                Image(tab.icon)
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: imageHeight)
                                    .foregroundColor(
                                        selectedTab == tab ? Color("main") : Color("gray400")
                                    )
                                Spacer().frame(height: imageToText)
                                Text(tab.title)
                                    .font(.custom("Pretendard", size: tabFontSize))
                                    .foregroundColor(
                                        selectedTab == tab ? Color("main") : Color("gray400")
                                    )
                                Spacer().frame(height: textToSafeArea)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .frame(height: tabBarHeight)
                .background(Color("pointwhite").ignoresSafeArea(edges: .bottom))
                .shadow(color: Color.black.opacity(0.05), radius: 4, y: -2)
            }
        }
        .fullScreenCover(isPresented: $showWalkDogSelection) {
            DogSelectionView(
                isWalkMode: true,
                onComplete: { dogs in
                    showWalkDogSelection = false
                    switch walkStartType {
                    case .direct:
                        showStartWalk = true
                    case .recommend:
                        showSelectWaypoint = true
                    }
                },
                onSkip: { dogs in
                    showWalkDogSelection = false
                    switch walkStartType {
                    case .direct:
                        showStartWalk = true
                    case .recommend:
                        showSelectWaypoint = true
                    }
                },
                onCancel: {
                    showWalkDogSelection = false
                }
            )
            .environmentObject(dogVM)
        }
        .fullScreenCover(isPresented: $showSelectWaypoint) {
            NavigationStack {
                SelectWaypointView(
                    onBack: { showSelectWaypoint = false },
                    onFinish: { route in
                        selectedRouteOption = route
                        showSelectWaypoint = false
                        showStartWalk = true
                    }
                )
                .environmentObject(dogVM)
            }
        }
        .fullScreenCover(isPresented: $showStartWalk) {
            NavigationStack {
                StartWalkView(routeOption: selectedRouteOption)
                    .environmentObject(dogVM)
            }
        }
        .dogSelectionSheet(isPresented: $showingDogSelection)
    }
}

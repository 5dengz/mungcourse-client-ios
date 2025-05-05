//
//  ContentView.swift
//  mungcourse
//
//  Created by Kyoungho Eom on 4/6/25.
//

import SwiftUI

struct ContentView: View {
    enum Tab: Int, CaseIterable {
        case home, startWalk, routine, history, profile
        var title: String {
            switch self {
            case .home: return "홈"
            case .startWalk: return "산책 시작"
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
    @State private var overlayBackgroundTab: Tab? = nil
    @State private var isStartWalkOverlayPresented = false
    @State private var showSelectWaypoint = false
    @State private var showRecommendCourse = false
    @State private var showStartWalk = false
    @State private var showingDogSelection = false
    @State private var showWalkDogSelection = false // 산책용 강아지 선택 화면
    @EnvironmentObject var dogVM: DogViewModel

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
                let backgroundTab = overlayBackgroundTab ?? selectedTab
                switch backgroundTab {
                case .home:
                    HomeView(
                        selectedTab: $selectedTab,
                        showingDogSelection: $showingDogSelection,
                        selectedDog: $dogVM.selectedDog,
                        dogs: dogVM.dogs,
                        isStartWalkOverlayPresented: $isStartWalkOverlayPresented,
                        onSelectCourse: {
                            showSelectWaypoint = true
                        }
                    )
                case .startWalk:
                    HomeView(
                        selectedTab: $selectedTab,
                        showingDogSelection: $showingDogSelection,
                        selectedDog: $dogVM.selectedDog,
                        dogs: dogVM.dogs,
                        isStartWalkOverlayPresented: $isStartWalkOverlayPresented,
                        onSelectCourse: {
                            showSelectWaypoint = true
                        }
                    )
                case .routine:
                    RoutineSettingsView()
                case .history:
                    WalkHistoryView()
                case .profile:
                    ProfileTabView(showingDogSelection: $showingDogSelection)
                }
            }

            VStack(spacing: 0) {
                Spacer()
                HStack {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Button(action: {
                            if tab == .startWalk {
                                overlayBackgroundTab = selectedTab
                                isStartWalkOverlayPresented = true
                            } else {
                                selectedTab = tab
                                overlayBackgroundTab = nil
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
                .background(Color.white.ignoresSafeArea(edges: .bottom))
                .shadow(color: Color.black.opacity(0.05), radius: 4, y: -2)
            }
        }
        .startWalkTabSheet(
            isPresented: $isStartWalkOverlayPresented,
            onSelectWaypoint: {
                showWalkDogSelection = true // 경유지 선택 전에 강아지 선택 화면 표시
            },
            onRecommendCourse: {
                showWalkDogSelection = true // AI 추천 코스 선택 전에 강아지 선택 화면 표시
            }
        )
        .fullScreenCover(isPresented: $showWalkDogSelection) {
            // 산책 강아지 선택 완료 후 선택한 모드에 따라 다른 화면 표시
            DogSelectionView(
                isWalkMode: true,
                onComplete: {
                    if isStartWalkOverlayPresented {
                        isStartWalkOverlayPresented = false
                        showStartWalk = true
                    }
                },
                onSkip: {
                    if isStartWalkOverlayPresented {
                        isStartWalkOverlayPresented = false
                        showStartWalk = true
                    }
                },
                onCancel: {
                    // 취소 시 메인 화면으로 돌아감
                }
            )
            .environmentObject(dogVM)
        }
        .fullScreenCover(isPresented: $showSelectWaypoint) {
            NavigationStack {
                SelectWaypointView(onBack: {
                    showSelectWaypoint = false
                })
            }
        }
        .fullScreenCover(isPresented: $showRecommendCourse) {
            NavigationStack {
                RecommendCourseView(onBack: {
                    showRecommendCourse = false
                    isStartWalkOverlayPresented = true
                })
            }
        }
        .fullScreenCover(isPresented: $showStartWalk) {
            NavigationStack {
                StartWalkView()
                    .environmentObject(dogVM)
            }
        }
        .dogSelectionSheet(isPresented: $showingDogSelection, selectedDog: $dogVM.selectedDog, dogs: dogVM.dogs)
    }
}

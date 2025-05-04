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
    @State private var showingDogSelection = false
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
                        dogName: $dogVM.selectedDogName,
                        availableDogs: dogVM.dogNames,
                        isStartWalkOverlayPresented: $isStartWalkOverlayPresented
                    )
                case .startWalk:
                    HomeView(
                        selectedTab: $selectedTab,
                        showingDogSelection: $showingDogSelection,
                        dogName: $dogVM.selectedDogName,
                        availableDogs: dogVM.dogNames,
                        isStartWalkOverlayPresented: $isStartWalkOverlayPresented
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
                showSelectWaypoint = true
            },
            onRecommendCourse: {
                showRecommendCourse = true
            }
        )
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
        .dogSelectionSheet(isPresented: $showingDogSelection, selectedDog: $dogVM.selectedDogName, dogs: dogVM.dogNames)
    }
}

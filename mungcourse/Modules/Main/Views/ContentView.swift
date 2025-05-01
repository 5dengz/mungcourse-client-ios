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
    @State private var isStartWalkOverlayPresented: Bool = false
    @State private var showSelectWaypoint: Bool = false
    @State private var showRecommendCourse: Bool = false
    private let imageHeight: CGFloat = 24
    private let imageToBorder: CGFloat = 10
    private let imageToText: CGFloat = 3
    private let textToSafeArea: CGFloat = 1
    private var tabBarHeight: CGFloat {
        imageToBorder + imageHeight + imageToText + tabFontSize + textToSafeArea
    }
    private let tabFontSize: CGFloat = 12
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                let backgroundTab = overlayBackgroundTab ?? selectedTab
                switch backgroundTab {
                case .home:
                    HomeView(selectedTab: $selectedTab)
                case .routine:
                    RoutineSettingsView()
                case .history:
                    WalkHistoryView()
                case .profile:
                    ProfileTabView()
                case .startWalk:
                    HomeView(selectedTab: $selectedTab)
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
                                    .foregroundColor(selectedTab == tab ? Color("main") : Color("gray400"))
                                Spacer().frame(height: imageToText)
                                Text(tab.title)
                                    .font(.custom("Pretendard", size: tabFontSize))
                                    .foregroundColor(selectedTab == tab ? Color("main") : Color("gray400"))
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
            if isStartWalkOverlayPresented {
                StartWalkTabView(
                    isOverlayPresented: $isStartWalkOverlayPresented,
                    onSelectWaypoint: {
                        showSelectWaypoint = true
                        isStartWalkOverlayPresented = false
                    },
                    onRecommendCourse: {
                        showRecommendCourse = true
                        isStartWalkOverlayPresented = false
                    }
                )
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .fullScreenCover(isPresented: $showSelectWaypoint) {
            NavigationStack {
                SelectWaypointView(onBack: {
                    showSelectWaypoint = false
                    isStartWalkOverlayPresented = true
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
        .onChange(of: isStartWalkOverlayPresented) { newValue in
            if !newValue {
                overlayBackgroundTab = nil
            }
        }
    }
}


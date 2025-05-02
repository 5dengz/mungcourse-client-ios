import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: ContentView.Tab
    @Binding var showingDogSelection: Bool
    @Binding var dogName: String
    let availableDogs: [String]

    var body: some View {
        ScrollView {
            VStack(spacing: 35) {
                ProfileArea(
                    selectedTab: $selectedTab,
                    showingDogSelection: $showingDogSelection,
                    dogName: $dogName,
                    availableDogs: availableDogs
                )
                ButtonArea()
                NearbyTrailsView()
                // WalkIndexView()
                PastRoutesView()
                    .padding(.bottom, 35)
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .navigationTitle("홈")
    }
}

struct ProfileArea: View {
    @Binding var selectedTab: ContentView.Tab
    @Binding var showingDogSelection: Bool
    @Binding var dogName: String
    let availableDogs: [String]

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            VStack(alignment: .leading, spacing: 5) {
                Text("반가워요")
                    .font(.custom("Pretendard-SemiBold", size: 24))

                HStack(spacing: 8) {
                    Button(action: {
                        showingDogSelection = true
                        print("강아지 이름 변경 버튼 탭됨.")
                    }) {
                        HStack(spacing: 4) {
                            Text(dogName)
                                .font(.custom("Pretendard-SemiBold", size: 24))
                                .foregroundColor(Color("AccentColor"))
                            Image(systemName: "chevron-down")
                                .font(.caption)
                                .foregroundColor(Color("AccentColor"))
                        }
                        .overlay(
                            Rectangle()
                                .frame(height: 2)
                                .offset(y: 3)
                                .foregroundColor(Color("AccentColor")),
                            alignment: .bottomLeading
                        )
                    }
                    .buttonStyle(.plain)

                    Text("보호자님!")
                        .font(.custom("Pretendard-SemiBold", size: 24))
                }
            }

            Spacer()

            Button(action: {
                selectedTab = .profile
            }) {
                Image("profile_empty")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical)
    }
}

struct ButtonArea: View {
    var body: some View {
        HStack(spacing: 9) {
            MainButton(
                title: "산책 시작",
                imageName: "start_walk",
                backgroundColor: Color("AccentColor"),
                foregroundColor: Color("white"),
                action: {
                    print("산책 시작 버튼 탭됨")
                }
            )
            MainButton(
                title: "코스 선택",
                imageName: "select_course",
                backgroundColor: Color("white"),
                foregroundColor: Color("main"),
                action: {
                    print("코스 선택 버튼 탭됨")
                }
            )
        }
    }
}

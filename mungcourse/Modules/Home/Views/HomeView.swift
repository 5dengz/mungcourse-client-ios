import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dogVM: DogViewModel
    @Binding var selectedTab: ContentView.Tab
    @Binding var isStartWalkOverlayPresented: Bool
    var onSelectCourse: () -> Void

    @State private var showingDogSelection: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 35) {
                ProfileArea(
                    selectedTab: $selectedTab,
                    showingDogSelection: $showingDogSelection,
                    selectedDog: $dogVM.selectedDog,
                    dogs: dogVM.dogs
                )
                ButtonArea(
                    isStartWalkOverlayPresented: $isStartWalkOverlayPresented,
                    onSelectCourse: onSelectCourse
                )
                NearbyTrailsView()
                PastRoutesView()
                    .padding(.bottom, 42)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .navigationTitle("홈")
        .dogSelectionSheet(isPresented: $showingDogSelection)
        .fullScreenCover(isPresented: $showingDogSelection) {
            RegisterDogView(onComplete: {
                dogVM.fetchDogs()
            }, showBackButton: true)
            .environmentObject(dogVM)
        }
    }
}

struct ProfileArea: View {
    @Binding var selectedTab: ContentView.Tab
    @Binding var showingDogSelection: Bool
    @Binding var selectedDog: Dog?
    let dogs: [Dog]

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
                            Text(selectedDog?.name ?? "")
                                .font(.custom("Pretendard-SemiBold", size: 24))
                                .foregroundColor(Color("AccentColor"))
                            Image("arrow_down")
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
                if let urlString = selectedDog?.dogImgUrl, let url = URL(string: urlString), !urlString.isEmpty {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure(_):
                            Image("profile_empty").resizable().scaledToFill()
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                } else {
                    Image("profile_empty")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.vertical)
    }
}

struct ButtonArea: View {
    @Binding var isStartWalkOverlayPresented: Bool
    var onSelectCourse: () -> Void
    
    var body: some View {
        HStack(spacing: 9) {
            MainButton(
                title: "산책 시작",
                imageName: "start_walk",
                backgroundColor: Color("main"),
                foregroundColor: Color("pointwhite"),
                action: {
                    isStartWalkOverlayPresented = true
                }
            )
            MainButton(
                title: "코스 선택",
                imageName: "select_course",
                backgroundColor: Color("pointwhite"),
                foregroundColor: Color("main"),
                action: {
                    onSelectCourse()
                }
            )
        }
    }
}

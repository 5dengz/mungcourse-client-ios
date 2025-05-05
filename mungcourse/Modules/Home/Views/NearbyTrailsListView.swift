import SwiftUI

struct NearbyTrailsListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = NearbyTrailsViewModel()
    @State private var categories: [String] = ["전체", "공원", "산책로", "카페"]
    @State private var selectedCategory: String? = nil
    @State private var selectedPlace: DogPlace? = nil
    @State private var showDetail = false

    var body: some View {
        VStack(spacing: 0) {
            // 공통 헤더
            CommonHeaderView(leftIcon: "arrow_back", leftAction: { dismiss() }, title: "주변 산책로")
            .padding(.top, 16)
            .padding(.bottom, 8)
            // 카테고리 필터
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { category in
                        let isSelected = (category == "전체" && selectedCategory == nil) || (selectedCategory == category)
                        Button {
                            selectedCategory = (category == "전체" ? nil : category)
                            viewModel.fetchNearbyDogPlaces(category: selectedCategory)
                        } label: {
                            Text(category)
                                .font(.custom("Pretendard-Regular", size: 14))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(isSelected ? Color("main") : Color("gray300"))
                                .foregroundColor(isSelected ? .Color("pointwhite") : .Color("gray400"))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            Divider()
            // 장소 리스트
            Group {
                if viewModel.isLoading {
                    ProgressView("불러오는 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.dogPlaces) { place in
                                TrailItemView(
                                    trailName: place.name,
                                    distance: String(format: "%.1fkm", place.distance / 1000),
                                    imageName: place.dogPlaceImgUrl ?? "",
                                    roundTripTime: place.openingHours ?? "",
                                    category: place.category
                                )
                                .onTapGesture {
                                    selectedPlace = place
                                    showDetail = true
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .onAppear {
            viewModel.fetchNearbyDogPlaces()
        }
        .fullScreenCover(isPresented: $showDetail) {
            if let place = selectedPlace {
                NearbyTrailMapDetailView(place: place)
            }
        }
    }
}


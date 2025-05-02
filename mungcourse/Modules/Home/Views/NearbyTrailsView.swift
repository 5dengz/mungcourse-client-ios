import SwiftUI

struct NearbyTrailsView: View {
    @StateObject private var viewModel = NearbyTrailsViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 상단 영역: 제목과 더보기 버튼
            HStack {
                Text("주변 산책로")
                    .font(.custom("Pretendard-SemiBold", size: 18))
                Spacer()
                Button("더보기") {
                    // TODO: 더보기 액션 구현
                    print("주변 산책로 더보기 탭됨")
                }
                .font(.custom("Pretendard-Regular", size: 14))
                .foregroundColor(Color("gray800"))
            }
            .padding(.bottom, 5)

            if viewModel.isLoading {
                ProgressView("장소를 불러오는 중...")
                    .frame(height: 150)
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .frame(height: 150)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(viewModel.dogPlaces) { place in
                            TrailItemView(
                                trailName: place.name,
                                distance: String(format: "%.1fkm", place.distance / 1000),
                                imageName: place.dogPlaceImgUrl ?? "",
                                roundTripTime: place.openingHours ?? "",
                                category: place.category
                            )
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .cornerRadius(10)
        .onAppear {
            viewModel.fetchNearbyDogPlaces()
        }
    }
}

#Preview {
    NearbyTrailsView()
        .padding()
}

import SwiftUI

struct SelectWaypointView: View {
    let onBack: () -> Void
    @StateObject private var viewModel = SelectWaypointViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            CommonHeaderView(leftIcon: "arrow_back", leftAction: {
                onBack()
            }, title: "경유지 선택")
            
            // 검색 입력 필드
            HStack {
                Image("icon_search")
                    .resizable()
                    .frame(width: 22, height: 22)
                TextField("가고 싶은 장소를 검색하세요", text: $viewModel.searchText)
                    .font(Font.custom("Pretendard", size: 14))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.clearSearch()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
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
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.dogPlaces) { place in
                            DogPlaceResultRow(place: place)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                        }
                        
                        if viewModel.dogPlaces.isEmpty && !viewModel.searchText.isEmpty {
                            Text("검색 결과가 없습니다")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 32)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // 화면이 나타날 때 위치 업데이트 시작
            GlobalLocationManager.shared.startUpdatingLocation()
        }
    }
}

// 검색 결과 행 컴포넌트
struct DogPlaceResultRow: View {
    let place: DogPlace
    
    var body: some View {
        HStack(spacing: 12) {
            // 이미지 (있는 경우)
            if let imageUrl = place.dogPlaceImgUrl, !imageUrl.isEmpty {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 50, height: 50)
                .cornerRadius(8)
            } else {
                // 이미지 없는 경우 대체 이미지
                Image(systemName: "pawprint.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray.opacity(0.7))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                HStack(spacing: 8) {
                    // 카테고리
                    Text(place.category)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    // 거리
                    Text(formatDistance(place.distance))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                // 영업시간 (있는 경우)
                if let hours = place.openingHours, !hours.isEmpty {
                    Text(hours)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    // 거리 표시 형식 변환
    private func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            let kmDistance = distance / 1000
            return String(format: "%.1fkm", kmDistance)
        }
    }
}

#Preview {
    SelectWaypointView(onBack: { })
} 
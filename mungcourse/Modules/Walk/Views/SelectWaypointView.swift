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
                } else {
                    Image("icon_search")
                        .resizable()
                        .frame(width: 22, height: 22)
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
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.dogPlaces) { place in
                            DogPlaceResultRow(place: place, isSelected: viewModel.isSelected(place.id), onSelect: {
                                viewModel.toggleSelection(for: place.id)
                            })
                            .padding(.horizontal, 20)
                        }
                        
                        if viewModel.dogPlaces.isEmpty && !viewModel.searchText.isEmpty {
                            Text("검색 결과가 없습니다")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 32)
                        }
                    }
                    .padding(.vertical, 12)
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
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // 왼쪽 아이콘
            Image("icon_search")
                .resizable()
                .frame(width: 22, height: 22)
            
            // 장소명
            Text(place.name)
                .font(Font.custom("Pretendard-Regular", size: 16))
                .foregroundColor(.black)
            
            Spacer()
            
            // 선택 버튼
            Button(action: onSelect) {
                ZStack {
                    Circle()
                        .stroke(Color("main"), lineWidth: 1)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Circle()
                            .fill(Color("main"))
                            .frame(width: 22, height: 22)
                        
                        Image("icon_check")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 22, height: 22)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(16)
    }
}

#Preview {
    SelectWaypointView(onBack: { })
} 
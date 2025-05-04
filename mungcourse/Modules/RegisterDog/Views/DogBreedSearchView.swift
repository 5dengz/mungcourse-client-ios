import SwiftUI

struct DogBreedSearchView: View {
    let onBack: () -> Void
    let onSelect: (String) -> Void
    @StateObject private var viewModel = DogBreedSearchViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            CommonHeaderView(leftIcon: "arrow_back", leftAction: {
                onBack()
            }, title: "견종 선택")
            
            // 검색 입력 필드
            HStack {
                TextField("견종을 검색하세요", text: $viewModel.searchText)
                    .font(Font.custom("Pretendard-SemiBold", size: 15))
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
            
            // 검색 결과 목록
            ScrollView {
                LazyVStack(spacing: 12) {
                    if viewModel.filteredBreeds.isEmpty && !viewModel.searchText.isEmpty {
                        EmptyBreedResultView()
                    } else {
                        ForEach(viewModel.filteredBreeds, id: \.self) { breed in
                            BreedResultRow(breed: breed, isSelected: viewModel.selectedBreed == breed, onSelect: {
                                viewModel.selectBreed(breed)
                                onSelect(breed)
                                dismiss()
                            })
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.vertical, 12)
            }
        }
        .navigationBarHidden(true)
    }
}

// 검색 결과 행 컴포넌트
struct BreedResultRow: View {
    let breed: String
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // 왼쪽 아이콘
            Image("icon_search")
                .resizable()
                .frame(width: 22, height: 22)
            
            // 견종명
            Text(breed)
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
        .background(Color.white)
        .cornerRadius(12)
    }
}

// 검색 결과가 없을 때 보여줄 뷰
struct EmptyBreedResultView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "magnifyingglass")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(Color("gray400"))
                .padding(.top, 40)
            
            Text("검색어와 일치하는 견종이 없습니다")
                .font(Font.custom("Pretendard-Regular", size: 16))
                .foregroundColor(Color("gray600"))
            
            Text("다른 검색어로 시도해보세요")
                .font(Font.custom("Pretendard-Regular", size: 14))
                .foregroundColor(Color("gray400"))
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
}

#Preview {
    DogBreedSearchView(onBack: {}, onSelect: { _ in })
}
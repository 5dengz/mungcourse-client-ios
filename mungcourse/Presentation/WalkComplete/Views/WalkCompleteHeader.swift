import SwiftUI
import Combine

struct WalkCompleteHeader: View {
    let walkDate: Date
    let onClose: () -> Void
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: walkDate)
    }
    
    var body: some View {
        // 시스템 네비게이션 바 숨김 (최상단 뒤로가기 버튼 제거)
        // 커스텀 헤더 UI는 그대로 유지
        // navigationBarHidden(true) 필요시 추가

        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate)
                    .font(.custom("Pretendard", size: 16).weight(.semibold))
                    .foregroundColor(Color("pointblack"))
                Text("오늘도 무사히")
                    .font(.custom("Pretendard", size: 24))
                    .foregroundColor(Color("pointblack"))
                Text("산책 완료!")
                    .font(.custom("Pretendard", size: 24).weight(.semibold))
                    .foregroundColor(Color("main"))
            }
            Spacer()
            VStack {
                Spacer()
                if let url = mainDogImgUrl, let imgUrl = URL(string: url) {
                    AsyncImage(url: imgUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                                .scaledToFill()
                        case .failure:
                            Image("profile_empty")
                                .resizable()
                                .scaledToFill()
                        @unknown default:
                            Image("profile_empty")
                                .resizable()
                                .scaledToFill()
                        }
                    }
                    .frame(width: 84, height: 84)
                    .clipShape(Circle())
                    .background(Circle().fill(Color("gray200")))
                } else {
                    Image("profile_empty")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 84, height: 84)
                        .clipShape(Circle())
                        .background(Circle().fill(Color("gray200")))
                }
                Spacer()
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 24)
        .padding(.bottom, 12)
        .frame(height: 160)
        .background(Color("pointhite"))
        .shadow(color: Color("pointblack").opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - 메인 반려견 이미지 비동기 로딩
    @State private var mainDogImgUrl: String? = nil
    
    @State private var cancellables = Set<AnyCancellable>()
    private func loadMainDog() {
        DogService.shared.fetchMainDog()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("[WalkCompleteHeader] 메인 반려견 정보 불러오기 실패: \(error)")
                }
            }, receiveValue: { dog in
                mainDogImgUrl = dog.dogImgUrl
            })
            .store(in: &cancellables)
    }
    
    init(walkDate: Date, onClose: @escaping () -> Void) {
        self.walkDate = walkDate
        self.onClose = onClose
        // 뷰가 생성될 때 메인 반려견 이미지 로딩
        loadMainDog()
    }
}


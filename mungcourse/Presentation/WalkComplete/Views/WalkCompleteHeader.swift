import SwiftUI
import Combine

struct WalkCompleteHeader: View {
    // 직접 DogViewModel 인스턴스를 받도록 변경
    var dogViewModel: DogViewModel
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
                if let dog = dogViewModel.mainDog, let url = dog.dogImgUrl, !url.isEmpty, let imgUrl = URL(string: url) {
                    AsyncImage(url: imgUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                                .scaledToFill()
                        case .failure(let error):
                            // 이미지 로드 실패 시 로그 추가
                            let _ = print("[WalkCompleteHeader] 이미지 로드 실패: \(error), URL: \(url)")
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
                    // dogImgUrl이 없을 때 기본 이미지만 표시 (로그 출력 제거)
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
        // onAppear에서 한 번만 메인 반려견을 로드하도록 수정
        .onAppear {
            loadMainDog()
        }
    }
    
    // MARK: - 메인 반려견 이미지 관련
    private var mainDogImgUrl: String? {
        dogViewModel.mainDog?.dogImgUrl
    }
    
    private func loadMainDog() {
        // 이미 메인 반려견 정보가 있다면 불필요한 재로딩 방지
        if dogViewModel.mainDog != nil {
            return
        }
        
        Task {
            do {
                try await dogViewModel.fetchMainDog()
                // 필요한 경우에만 로그 출력
                if dogViewModel.mainDog != nil {
                    print("[WalkCompleteHeader] 메인 반려견 정보 로드 성공: \(dogViewModel.mainDog?.name ?? "없음")")
                }
            } catch {
                print("[WalkCompleteHeader] 메인 반려견 정보 불러오기 실패: \(error)")
            }
        }
    }
    
    init(walkDate: Date, onClose: @escaping () -> Void, dogViewModel: DogViewModel) {
        self.walkDate = walkDate
        self.onClose = onClose
        self.dogViewModel = dogViewModel
        // 초기화 과정에서 메인 반려견 이미지 로딩을 하지 않음 (onAppear에서 처리)
    }
}


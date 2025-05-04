import SwiftUI
import Combine

struct AccountDeletionConfirmView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    @StateObject private var viewModel = AccountDeletionViewModel()
    @State private var selectedReason: String? = nil
    
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더 (AccountDeletionView와 동일)
            CommonHeaderView(
                leftIcon: "",
                leftAction: { dismiss() },
                title: "회원 탈퇴"
            )
            .padding(.top, 16)
            .padding(.bottom, 16)
            
            ScrollView {
                VStack(spacing: 30) {
                    // 본문 텍스트 - "소중한 산책 기록"만 main 컬러로 변경
                    VStack(spacing: 8) {
                        Text("잠시만요!")
                            .font(.custom("Pretendard-SemiBold", size: 18))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 0) {
                            Text("탈퇴하시면 ")
                                .font(.custom("Pretendard-SemiBold", size: 18))
                                .foregroundColor(.black)
                            
                            Text("소중한 산책 기록")
                                .font(.custom("Pretendard-SemiBold", size: 18))
                                .foregroundColor(Color("main"))
                            
                            Text("이")
                                .font(.custom("Pretendard-SemiBold", size: 18))
                                .foregroundColor(.black)
                        }
                        
                        Text("영영 사라져요 😢")
                            .font(.custom("Pretendard-SemiBold", size: 18))
                            .foregroundColor(.black)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, 34)
                    .padding(.horizontal, 16)
                    
                    // 강아지 프로필 사진들 (65x65 크기로 중앙 배열)
                    if !viewModel.dogs.isEmpty {
                        HStack(spacing: 10) {
                            ForEach(viewModel.dogs) { dog in
                                if let imageUrl = dog.dogImgUrl {
                                    AsyncImage(url: URL(string: imageUrl)) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 65, height: 65)
                                                .clipShape(Circle())
                                        case .failure(_):
                                            Image(systemName: "pawprint.circle.fill")
                                                .resizable()
                                                .frame(width: 65, height: 65)
                                                .foregroundColor(Color("gray300"))
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 65, height: 65)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                } else {
                                    Image(systemName: "pawprint.circle.fill")
                                        .resizable()
                                        .frame(width: 65, height: 65)
                                        .foregroundColor(Color("gray300"))
                                }
                            }
                        }
                        .padding(.vertical, 20)
                    }
                    
                    // 산책 통계 정보
                    VStack(spacing: 12) {
                        // 총 산책 횟수
                        StatisticItemView(
                            title: "총 산책 횟수",
                            value: "\(viewModel.totalWalkCount)회"
                        )
                        
                        // 총 산책 시간
                        StatisticItemView(
                            title: "총 산책 시간",
                            value: "\(viewModel.totalWalkMinutes)분"
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    // 하단 버튼: 취소 및 탈퇴하기
                    VStack(spacing: 12) {
                        CommonFilledButton(
                            title: "취소",
                            action: {
                                dismiss()
                            },
                            isEnabled: true,
                            backgroundColor: Color("main"),
                            foregroundColor: .white,
                            cornerRadius: 8
                        )
                        .padding(.horizontal, 16)
                        .frame(height: 55)
                        
                        if isLoading {
                            // 로딩 중에는 프로그레스 뷰 표시
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color("gray100"))
                                .cornerRadius(8)
                        } else {
                            // 로딩 중이 아닐 때는 CommonFilledButton 사용
                            CommonFilledButton(
                                title: "탈퇴하기",
                                action: {
                                    isLoading = true
                                    // 실제 탈퇴 처리는 여기서 진행
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        isLoading = false
                                        onDelete()
                                    }
                                },
                                isEnabled: !isLoading,
                                backgroundColor: Color("gray100"),
                                foregroundColor: Color("gray700"),
                                cornerRadius: 8
                            )
                            .frame(height: 55)
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 48)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            viewModel.loadData()
        }
    }
}

// 통계 정보를 표시하는 커스텀 뷰
struct StatisticItemView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(title)
                .font(Font.custom("Pretendard-Regular", size: 16))
                .foregroundColor(.black)
                .padding(.leading, 16)
            
            Spacer()
            
            Text(value)
                .font(Font.custom("Pretendard-Regular", size: 16))
                .foregroundColor(Color("main"))
                .padding(.trailing, 16)
        }
        .frame(width: 330, height: 57)
        .background(
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(
                    color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), 
                    radius: 12, 
                    y: 2
                )
        )
    }
}

// ViewModel 추가
class AccountDeletionViewModel: ObservableObject {
    @Published var dogs: [Dog] = []
    @Published var totalWalkCount: Int = 0
    @Published var totalWalkMinutes: Int = 0
    @Published var isLoading: Bool = false
    
    private let dogService = DogService.shared
    private var cancellables = Set<AnyCancellable>()
    
    func loadData() {
        isLoading = true
        
        // 강아지 목록 가져오기
        dogService.fetchDogs()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    print("강아지 목록 조회 실패: \(error)")
                }
            } receiveValue: { [weak self] dogs in
                self?.dogs = dogs
                self?.fetchWalkRecordsForAllDogs()
            }
            .store(in: &cancellables)
    }
    
    func fetchWalkRecordsForAllDogs() {
        let group = DispatchGroup()
        var totalCount = 0
        var totalSeconds = 0
        
        for dog in dogs {
            group.enter()
            
            Task {
                do {
                    let records = try await dogService.fetchWalkRecords(dogId: dog.id)
                    totalCount += records.count
                    
                    // 총 산책 시간 계산 (초 단위)
                    let seconds = records.reduce(0) { $0 + $1.durationSec }
                    totalSeconds += seconds
                    
                    group.leave()
                } catch {
                    print("강아지 \(dog.id)의 산책 기록 조회 실패: \(error)")
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.totalWalkCount = totalCount
            self?.totalWalkMinutes = totalSeconds / 60 // 초를 분으로 변환
            self?.isLoading = false
        }
    }
}

#if DEBUG
struct AccountDeletionConfirmView_Previews: PreviewProvider {
    static var previews: some View {
        AccountDeletionConfirmView(onDelete: {})
    }
}
#endif
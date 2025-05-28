import SwiftUI
import Combine

struct AccountDeletionConfirmView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    @StateObject private var viewModel = AccountDeletionViewModel()
    @State private var showDeleteConfirmModal = false // 탈퇴 확인 모달 표시 상태
    
    let onDelete: () -> Void
    
    var body: some View {
        ZStack {
            // 메인 뷰
            VStack(spacing: 0) {
                // 헤더 (AccountDeletionView와 동일)
                CommonHeaderView(
                    leftIcon: "",
                    leftAction: { dismiss() },
                    title: "회원 탈퇴"
                )
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
                            
                            Text("영영 사라져요. 😢")
                                .font(.custom("Pretendard-SemiBold", size: 18))
                                .foregroundColor(.black)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
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
                            .frame(maxWidth: .infinity)   // HStack을 전체 폭으로 확장
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
                    }
                }
                
                // 하단 버튼: 취소 및 탈퇴하기
                VStack(spacing: 12) {
                    if viewModel.isDeleting {
                        // 탈퇴 처리 중일 때는 프로그레스 뷰 표시 (첫 번째)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color("gray100"))
                            .cornerRadius(8)
                            .padding(.horizontal, 16)
                    } else {
                        // 탈퇴하기 버튼 (첫 번째)
                        CommonFilledButton(
                            title: "탈퇴하기",
                            action: {
                                showDeleteConfirmModal = true // 모달 표시
                            },
                            isEnabled: !viewModel.isDeleting,
                            backgroundColor: Color("gray100"),
                            foregroundColor: Color("gray700"),
                            cornerRadius: 8
                        )
                        .frame(width: UIScreen.main.bounds.width - 32)
                        .frame(height: 55)
                    }

                    // 취소 버튼 (두 번째)
                    CommonFilledButton(
                        title: "취소",
                        action: {
                            dismiss()
                        },
                        isEnabled: true,
                        backgroundColor: Color("main"),
                        foregroundColor: Color("pointwhite"),
                        cornerRadius: 8
                    )
                    .frame(width: UIScreen.main.bounds.width - 32)
                    .frame(height: 55)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 48)
            }
            .ignoresSafeArea(edges: .bottom)
            
            // 탈퇴 확인 모달
            if showDeleteConfirmModal {
                CommonPopupModal(
                    title: "회원 탈퇴", 
                    message: "회원 탈퇴 시 반려견 정보 및 산책 기록은\n모두 삭제되어 복구가 불가해요\n\n정말로 삭제하시겠어요?",
                    cancelText: "취소",
                    confirmText: "삭제",
                    cancelAction: {
                        showDeleteConfirmModal = false
                    },
                    confirmAction: {
                        showDeleteConfirmModal = false
                        // 회원 탈퇴 처리
                        viewModel.deleteAccount { success in
                            if success {
                                onDelete() // 성공 시 로그인 화면으로 이동
                            }
                        }
                    }
                )
            }
        }
        .onAppear {
            viewModel.loadData()
        }
        // 에러 알림 처리 (공통 IdentifiableError 사용)
        .alert(item: Binding<IdentifiableError?>(
            get: { viewModel.error != nil ? IdentifiableError(error: viewModel.error!) : nil },
            set: { _ in viewModel.error = nil }
        )) { identifiableError in
            Alert(
                title: Text("회원 탈퇴 실패"),
                message: Text(identifiableError.localizedDescription),
                dismissButton: .default(Text("확인"))
            )
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
                .foregroundColor(Color("pointblack"))
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
                .foregroundColor(Color("pointwhite"))
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
    @Published var isDeleting: Bool = false
    @Published var error: Error? = nil
    
    private let dogService = DogService.shared
    private let authService = AuthService.shared
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
    
    // 회원 탈퇴 기능
    func deleteAccount(completion: @escaping (Bool) -> Void) {
        isDeleting = true
        error = nil
        
        authService.deleteAccount()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] result in
                    self?.isDeleting = false
                    
                    switch result {
                    case .finished:
                        break
                    case .failure(let err):
                        self?.error = err
                        completion(false)
                    }
                },
                receiveValue: { success in
                    completion(success)
                }
            )
            .store(in: &cancellables)
    }
}

#if DEBUG
struct AccountDeletionConfirmView_Previews: PreviewProvider {
    static var previews: some View {
        AccountDeletionConfirmView(onDelete: {})
    }
}
#endif
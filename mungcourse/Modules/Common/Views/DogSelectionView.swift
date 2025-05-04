import SwiftUI

struct DogSelectionView: View {
    @EnvironmentObject var dogVM: DogViewModel
    @Environment(\.dismiss) private var dismiss
    
    // 제목과 부제목
    var title: String = "반려견을 선택해주세요"
    var subtitle: String = "프로필을 확인할\n반려견을 선택해주세요."
    
    // UI 요소 표시 여부 제어
    var showHeader: Bool = true
    var showAddDogButton: Bool = true
    var showCompleteButton: Bool = true
    var immediateSelection: Bool = false
    
    // 산책 모드 여부 (산책 시작 전 강아지 선택)
    var isWalkMode: Bool = false
    
    // 반려견 추가 화면으로 이동하기 위한 상태 변수
    @State private var showAddDogView = false
    
    // 선택 완료 시 실행할 액션
    var onComplete: (() -> Void)? = nil
    
    // 산책 시 건너뛰기 버튼 액션
    var onSkip: (() -> Void)? = nil
    
    // 산책 시 선택 취소 버튼 액션
    var onCancel: (() -> Void)? = nil
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더 (조건부 표시)
            if showHeader {
                CommonHeaderView(
                    leftIcon: "arrow_back",
                    leftAction: { dismiss() },
                    title: "반려견 선택"
                )
            } else if isWalkMode {
                // 산책 모드 헤더: 취소 버튼과 건너뛰기 버튼
                CommonHeaderView(
                    leftIcon: "arrow_back",
                    leftAction: {
                        dismiss()
                        onCancel?()
                    },
                    title: ""
                ) {
                    Button(action: {
                        dismiss()
                        onSkip?()
                    }) {
                        Text("건너뛰기")
                            .font(.custom("Pretendard-Regular", size: 16))
                            .foregroundColor(Color("main"))
                    }
                }
            }
            
            // 콘텐츠 영역
            VStack(spacing: 20) {
                // 제목 (산책 모드인 경우 다른 제목 사용)
                Text(isWalkMode ? "함께하는 반려견이 있나요?" : title)
                    .font(.custom("Pretendard-SemiBold", size: 24))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .padding(.top, showHeader ? 0 : 20)
                
                // 부제목 (산책 모드인 경우에만 표시하거나, subtitle이 비어있지 않은 경우만 표시)
                if isWalkMode || !subtitle.isEmpty {
                    Text(isWalkMode ? "산책 기록을 함께 저장할게요!" : subtitle)
                        .font(.custom("Pretendard-Regular", size: 14))
                        .foregroundColor(Color("gray600"))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                }
                
                // 반려견 그리드
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 28) {
                        // 기존 반려견 목록
                        ForEach(dogVM.dogs) { dog in
                            VStack(spacing: 11) {
                                ZStack {
                                    if let urlString = dog.dogImgUrl,
                                       let url = URL(string: urlString) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        } placeholder: {
                                            Circle()
                                                .fill(Color("gray300"))
                                        }
                                    } else {
                                        Circle()
                                            .fill(Color("gray300"))
                                    }
                                    
                                    // 현재 메인 반려견인 경우 체크 표시
                                    if dog.isMain {
                                        Circle()
                                            .fill(Color.black.opacity(0.4))
                                        Image("icon_check")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                    }
                                }
                                .frame(width: 135, height: 135)
                                .clipShape(Circle())

                                Text(dog.name)
                                    .font(.custom("Pretendard-Regular", size: 18))
                                    .foregroundColor(.black)
                            }
                            .onTapGesture {
                                dogVM.selectDog(dog)
                                dogVM.mainDog = dog
                                
                                // 즉시 선택 모드인 경우 바로 dismiss 호출
                                if immediateSelection || isWalkMode {
                                    dismiss()
                                    if isWalkMode {
                                        onComplete?()
                                    }
                                }
                            }
                        }
                        
                        // 반려견 추가 버튼 (조건부 표시 - 산책 모드에서는 표시하지 않음)
                        if showAddDogButton && !isWalkMode {
                            VStack(spacing: 11) {
                                ZStack {
                                    Circle()
                                        .fill(Color("gray300"))
                                    
                                    Image("icon_plus")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(Color("gray400"))
                                }
                                .frame(width: 135, height: 135)
                                
                                Text("반려견 추가")
                                    .font(.custom("Pretendard-Regular", size: 18))
                                    .foregroundColor(Color("gray400"))
                            }
                            .onTapGesture {
                                showAddDogView = true
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                
                Spacer()
                
                // 선택 완료 버튼 (조건부 표시 - 산책 모드에서는 항상 표시)
                if showCompleteButton && !isWalkMode {
                    CommonFilledButton(title: "선택 완료", action: {
                        dismiss()
                        onComplete?()
                    })
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                } else if isWalkMode {
                    CommonFilledButton(title: "선택 완료", action: {
                        dismiss()
                        onComplete?()
                    })
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .padding(.top, 20)
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            dogVM.fetchDogs()
        }
        .sheet(isPresented: $showAddDogView) {
            RegisterDogView(onComplete: {
                dogVM.fetchDogs()
            }, showBackButton: true)
        }
    }
}

#Preview {
    DogSelectionView()
        .environmentObject(DogViewModel())
}
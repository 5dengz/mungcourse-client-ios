import SwiftUI

struct DogSelectionView: View {
    @EnvironmentObject var dogVM: DogViewModel
    @Environment(\.dismiss) private var dismiss
    
    // 모드별 텍스트 처리를 위한 변수
    // 일반 모드에 사용되는 주요 텍스트 (현재는 사용하지 않음)
    var mainTitle: String = ""
    
    // 일반 모드에 사용되는 헤더 텍스트 (이것이 화면 상단에 표시되는 제목)
    var headerTitle: String = "반려견을 선택해주세요"
    
    // 산책 모드에 사용되는 텍스트
    private let walkModeTitle = "함께하는 반려견이 있나요?"
    private let walkModeSubtitle = "산책 기록을 함께 저장할게요!"
    
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
    var onComplete: (([Dog]) -> Void)? = nil
    
    // 산책 시 건너뛰기 버튼 액션
    var onSkip: (([Dog]) -> Void)? = nil
    
    // 산책 시 선택 취소 버튼 액션
    var onCancel: (() -> Void)? = nil
    
    @State private var selectedDogs: [Dog] = []
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 산책 모드일 때만 커스텀 헤더 표시
            if isWalkMode {
                HStack {
                    Button(action: {
                        dismiss()
                        onCancel?()
                    }) {
                        Text("취소")
                            .font(.custom("Pretendard-Regular", size: 18))
                            .foregroundColor(Color("main"))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                        onSkip?([])
                    }) {
                        Text("건너뛰기")
                            .font(.custom("Pretendard-Regular", size: 18))
                            .foregroundColor(Color("gray400"))
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
            }
            
            // 콘텐츠 영역
            VStack(spacing: 20) {
                // 텍스트 영역 VStack
                VStack(spacing: 8) {
                    // 제목 - 산책 모드와 일반 모드에 따라 다른 텍스트 사용
                    Text(isWalkMode ? walkModeTitle : headerTitle)
                        .font(.custom("Pretendard-SemiBold", size: 24))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                        .padding(.top, 20)
                    
                    // 부제목 영역 - 산책 모드일 때는 항상 표시, 아닐 때는 mainTitle이 있을 때만
                    if isWalkMode {
                        // 산책 모드 부제목
                        Text(walkModeSubtitle)
                            .font(.custom("Pretendard-Regular", size: 14))
                            .foregroundColor(Color("gray600"))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                    } else if !mainTitle.isEmpty {
                        // 일반 모드 - 더 이상 줄바꿈 처리 없이 단순 텍스트로 표시
                        Text(mainTitle)
                            .font(.custom("Pretendard-Regular", size: 14))
                            .foregroundColor(Color("gray600"))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                    }
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
                                    
                                    // 선택된 반려견 표시
                                    if isWalkMode && selectedDogs.contains(dog) {
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
                                if isWalkMode {
                                    if let idx = selectedDogs.firstIndex(of: dog) {
                                        selectedDogs.remove(at: idx)
                                    } else {
                                        selectedDogs.append(dog)
                                    }
                                } else {
                                    dogVM.selectDog(dog)
                                    dogVM.mainDog = dog
                                    if immediateSelection {
                                        dismiss()
                                    } else {
                                        dismiss()
                                        onComplete?([dog])
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
                                    .foregroundColor(Color("gray500"))
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
                
                // 선택 완료 버튼 (showCompleteButton이 true이거나 산책 모드일 때 표시)
                if showCompleteButton || isWalkMode {
                    CommonFilledButton(title: "선택 완료", action: {
                        dismiss()
                        onComplete?(selectedDogs)
                    })
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
                }
            }
            .padding(.top, 20)
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            dogVM.fetchDogs()
        }
        .fullScreenCover(isPresented: $showAddDogView) {
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
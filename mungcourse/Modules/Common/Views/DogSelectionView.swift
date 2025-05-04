import SwiftUI

struct DogSelectionView: View {
    @EnvironmentObject var dogVM: DogViewModel
    @Environment(\.dismiss) private var dismiss
    
    // 제목과 부제목
    var title: String = "반려견을 선택해주세요"
    var subtitle: String = "프로필을 확인할\n반려견을 선택해주세요"
    
    // UI 요소 표시 여부 제어
    var showHeader: Bool = true
    var showAddDogButton: Bool = true
    var showCompleteButton: Bool = true
    var immediateSelection: Bool = false
    
    // 반려견 추가 화면으로 이동하기 위한 상태 변수
    @State private var showAddDogView = false
    
    // 선택 완료 시 실행할 액션
    var onComplete: (() -> Void)? = nil
    
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
            }
            
            // 콘텐츠 영역
            VStack(spacing: 20) {
                // 제목
                Text(title)
                    .font(.custom("Pretendard-SemiBold", size: 24))
                    .multilineTextAlignment(.center)
                    .padding(.top, showHeader ? 0 : 20)
                
                // 부제목
                Text(subtitle)
                    .font(.custom("Pretendard-Regular", size: 14))
                    .foregroundColor(Color("gray600"))
                    .multilineTextAlignment(.center)
                
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
                                if immediateSelection {
                                    dismiss()
                                }
                            }
                        }
                        
                        // 반려견 추가 버튼 (조건부 표시)
                        if showAddDogButton {
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
                                    .foregroundColor(Color("gray300"))
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
                
                // 선택 완료 버튼 (조건부 표시)
                if showCompleteButton {
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
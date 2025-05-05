import SwiftUI
import UIKit

struct DogSelectionSheet: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var dogVM: DogViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("프로필 선택")
                .font(.custom("Pretendard-SemiBold", size: 18))
                .padding(.top, 36)
                .padding(.leading, 29)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 21) {
                    ForEach(dogVM.dogs) { dog in
                        VStack(alignment: .center, spacing: 9) {
                            ZStack {
                                AsyncImage(url: URL(string: dog.dogImgUrl ?? "")) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable()
                                            .scaledToFill()
                                    case .empty:
                                        ProgressView()
                                    case .failure:
                                        Image("profile_empty")
                                            .resizable()
                                            .scaledToFill()
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: 68, height: 68)
                                .clipShape(Circle())
                                .opacity(dogVM.selectedDog?.id == dog.id ? 0.6 : 1.0)
                                
                                if dogVM.selectedDog?.id == dog.id {
                                    Image("icon_check")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 43, height: 43)
                                }
                            }
                            
                            Text(dog.name)
                                .font(.custom("Pretendard-Regular", size: 15))
                                .foregroundColor(dogVM.selectedDog?.id == dog.id ? Color("main") : .black)
                        }
                        .onTapGesture {
                            // 메인 반려견을 선택하고 상세 정보 및 기록을 불러옵니다.
                            dogVM.selectDog(dog)
                            dogVM.mainDog(dog)
                            isPresented = false
                        }
                    }
                }
                .padding(.horizontal, 29)
                .padding(.top, 5)
            }
            
            Spacer()
        }
        .presentationDetents([.height(230)])
        .presentationCornerRadius(20)
        .onDisappear {
            // 시트가 사라질 때 필요한 작업이 있다면 여기에 추가
        }
    }
}

// 시트를 표시하기 위한 확장 - HomeView에서 사용
extension View {
    func dogSelectionSheet(isPresented: Binding<Bool>) -> some View {
        self.sheet(isPresented: isPresented) {
            DogSelectionSheet(isPresented: isPresented)
        }
    }
}

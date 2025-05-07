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
                                if let urlString = dog.dogImgUrl, !urlString.isEmpty, let url = URL(string: urlString) {
                                    AsyncImage(url: url) { phase in
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
                                } else {
                                    Image("profile_empty")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 68, height: 68)
                                        .clipShape(Circle())
                                        .opacity(dogVM.selectedDog?.id == dog.id ? 0.6 : 1.0)
                                }
                                
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
                            // 로그 추가: 현재 강아지 및 선택된 강아지 정보
                            print("[DogSelectionSheet] 현재 강아지 ID: \(dog.id), 이름: \(dog.name)")
                            print("[DogSelectionSheet] 이전 선택된 강아지: \(String(describing: dogVM.selectedDog))")
                            print("[DogSelectionSheet] 이전 메인 강아지: \(String(describing: dogVM.mainDog))")
                            
                            // 로그: 현재 선택한 강아지 및 현재 메인 강아지 정보
                            print("[DogSelectionSheet] 선택한 강아지: ID=\(dog.id), 이름=\(dog.name)")
                            print("[DogSelectionSheet] 이전 메인 강아지: \(String(describing: dogVM.mainDog))")
                            
                            // UI에 미리 반영 (사용자에게 즉시 피드백 제공)
                            dogVM.selectedDog = dog
                            dogVM.selectedDogName = dog.name
                            print("[DogSelectionSheet] UI 업데이트 완료 (API 호출 전)")
                            
                            // API 호출을 통한 대표 강아지 변경
                            Task {
                                do {
                                    // 사용자가 인지할 수 있도록 잠시 대기 
                                    try await Task.sleep(nanoseconds: 300_000_000) // 0.3초
                                    print("[DogSelectionSheet] setMainDog API 호출 시작 (dogId=\(dog.id))")
                                    
                                    // 성공 여부를 반환받음
                                    let success = await dogVM.setMainDog(dog.id)
                                    
                                    if success {
                                        print("[DogSelectionSheet] 대표 강아지 설정 성공! 메인 강아지=\(String(describing: dogVM.mainDog?.id))")
                                        // 시트 닫기 (성공 시에만)
                                        isPresented = false
                                        print("[DogSelectionSheet] 시트 닫기 완료")
                                    } else {
                                        print("[DogSelectionSheet] 대표 강아지 설정 API 실패")                                        
                                        // 여기서 실패 시 추가적인 처리를 할 수 있음
                                    }
                                } catch {
                                    print("[DogSelectionSheet] 대표 강아지 설정 예외 발생: \(error)")
                                }
                            }
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

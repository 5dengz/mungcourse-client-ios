import SwiftUI
import UIKit

struct DogSelectionSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedDog: String
    let dogs: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("프로필 선택")
                .font(.custom("Pretendard-SemiBold", size: 18))
                .padding(.top, 29)
                .padding(.leading, 29)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 21) {
                    ForEach(dogs, id: \.self) { dog in
                        VStack(alignment: .center, spacing: 9) {
                            ZStack {
                                Image("profile_empty")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 68, height: 68)
                                    .clipShape(Circle())
                                    .opacity(selectedDog == dog ? 0.6 : 1.0) // 더 어둡게 조정 (0.7 → 0.6)
                                
                                if selectedDog == dog {
                                    Image("icon_check")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 43, height: 43)
                                }
                            }
                            
                            Text(dog)
                                .font(.custom("Pretendard-Regular", size: 15))
                                .foregroundColor(selectedDog == dog ? Color("main") : .black) // 선택된 강아지 이름 색상 변경
                        }
                        .onTapGesture {
                            selectedDog = dog
                            isPresented = false
                        }
                    }
                }
                .padding(.horizontal, 29)
                .padding(.top, 10)
            }
            
            Spacer()
        }
        .presentationDetents([.height(260)])
        .onDisappear {
            // 시트가 사라질 때 필요한 작업이 있다면 여기에 추가
        }
    }
}

// 시트를 표시하기 위한 확장 - HomeView에서 사용
extension View {
    func dogSelectionSheet(isPresented: Binding<Bool>, selectedDog: Binding<String>, dogs: [String]) -> some View {
        self.sheet(isPresented: isPresented) {
            DogSelectionSheet(isPresented: isPresented, selectedDog: selectedDog, dogs: dogs)
        }
    }
}

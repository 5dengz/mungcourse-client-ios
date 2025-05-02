import SwiftUI
import UIKit

struct DogSelectionSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedDog: String
    let dogs: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("프로필 선택")
                .font(.custom("Pretendard-SemiBold", size: 20))
                .padding(.horizontal)
                .padding(.top)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(dogs, id: \.self) { dog in
                        VStack(alignment: .center, spacing: 8) {
                            Image("profile_empty")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(selectedDog == dog ? Color("AccentColor") : Color.clear, lineWidth: 2)
                                )
                            Text(dog)
                                .font(.custom("Pretendard-SemiBold", size: 16))
                                .foregroundColor(.black)
                        }
                        .onTapGesture {
                            selectedDog = dog
                            isPresented = false
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .frame(height: 260)
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .edgesIgnoringSafeArea(.bottom)
        .transition(.move(edge: .bottom))
        .animation(.easeInOut, value: isPresented)
    }
}

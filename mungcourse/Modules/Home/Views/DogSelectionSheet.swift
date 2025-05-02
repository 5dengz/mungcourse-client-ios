import SwiftUI
import UIKit

struct DogSelectionSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedDog: String
    let dogs: [String]
    @State private var dragOffsetY: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: geometry.size.height - 260)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isPresented = false
                    }
                VStack(alignment: .leading, spacing: 16) {
                    Text("프로필 선택")
                        .font(.custom("Pretendard-SemiBold", size: 20))

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
                    }

                    Spacer()
                }
                .padding(.horizontal, 29)
                .padding(.top, 29)
                .frame(height: 260)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .offset(y: dragOffsetY)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.height > 0 {
                                dragOffsetY = value.translation.height
                            }
                        }
                        .onEnded { value in
                            withAnimation(.easeInOut) {
                                if value.translation.height > 100 {
                                    isPresented = false
                                }
                                dragOffsetY = 0
                            }
                        }
                )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.all)
        .transition(.move(edge: .bottom))
        .animation(.easeInOut, value: isPresented)
    }
}

import SwiftUI

struct ProfileDogSelectionView: View {
    @EnvironmentObject var dogVM: DogViewModel
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("프로필을 확인할 반려견을 선택해주세요.")
                .font(.custom("Pretendard-SemiBold", size: 24))
                .multilineTextAlignment(.center)
                .padding(.top, 20)

            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 20) {
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
                                            .fill(Color.gray.opacity(0.2))
                                    }
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                }
                            }
                            .frame(width: 135, height: 135)
                            .clipShape(Circle())
                            .overlay(
                                Group {
                                    if dog.isMain {
                                        Circle()
                                            .fill(Color.black.opacity(0.4))
                                        Image("icon_check")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                    }
                                }
                            )

                            Text(dog.name)
                                .font(.custom("Pretendard-Regular", size: 18))
                                .foregroundColor(.black)
                        }
                        .onTapGesture {
                            dogVM.selectDog(dog)
                            dogVM.mainDog = dog
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            Spacer()
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            dogVM.fetchDogs()
        }
    }
}

#if DEBUG
struct ProfileDogSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileDogSelectionView()
            .environmentObject(DogViewModel())
    }
}
#endif 
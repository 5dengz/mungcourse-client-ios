import SwiftUI

struct ProfileSectionView: View {
    let nickname: String?
    let profileImageUrl: String?
    var onEdit: (() -> Void)?
    var onTapImage: (() -> Void)?
    var body: some View {
        VStack(spacing: 8) {
            if let urlStr = profileImageUrl, let url = URL(string: urlStr) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image("profile_empty")
                        .resizable()
                        .scaledToFill()
                }
                .frame(width: 127, height: 127)
                .clipShape(Circle())
            } else {
                Image("profile_empty")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 127, height: 127)
                    .clipShape(Circle())
            }
            Spacer().frame(height: 16)
            Text(nickname ?? "강아지 이름")
                .font(.title2)
                .fontWeight(Font.Weight.semibold)
            Button(action: { onEdit?() }) {
                Text("프로필 편집")
                    .font(.caption)
                    .fontWeight(Font.Weight.semibold)
                    .foregroundColor(Color("gray400"))
            }
        }
        .frame(maxWidth: .infinity)
    }
}
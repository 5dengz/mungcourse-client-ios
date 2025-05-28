import SwiftUI

struct ProfileSectionView: View {
    let nickname: String?
    let profileImageUrl: String?
    var onEdit: (() -> Void)?
    var onTapImage: (() -> Void)?
    
    // 초기화 시 로그 추가
    init(nickname: String?, profileImageUrl: String?, onEdit: (() -> Void)? = nil, onTapImage: (() -> Void)? = nil) {
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self.onEdit = onEdit
        self.onTapImage = onTapImage
        print("[ProfileSectionView] 초기화: nickname=\(String(describing: nickname)), profileImageUrl=\(String(describing: profileImageUrl))")
    }
    
    var body: some View {
        VStack(spacing: 8) {
            profileImageSection
            Spacer().frame(height: 16)
            Text(nickname ?? "강아지 이름")
                .font(.title2)
                .fontWeight(Font.Weight.semibold)
                .onAppear {
                    print("[ProfileSectionView] 표시된 이름: \(nickname ?? "강아지 이름 (기본값)")")
                }
            Button(action: { 
                print("[ProfileSectionView] 프로필 편집 버튼 클릭")
                onEdit?() 
            }) {
                Text("프로필 편집")
                    .font(.caption)
                    .fontWeight(Font.Weight.semibold)
                    .foregroundColor(Color("gray400"))
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            // 뷰가 나타날 때 로그 출력
            if let urlStr = profileImageUrl {
                print("[ProfileSectionView] 프로필 이미지 로드 시도: \(urlStr)")
            }
        }
    }
    
    // 프로필 이미지 섹션을 별도 계산 속성으로 분리
    private var profileImageSection: some View {
        Group {
            if let urlStr = profileImageUrl, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Image("profile_empty")
                            .resizable()
                            .scaledToFill()
                            .onAppear {
                                print("[ProfileSectionView] 프로필 이미지 로딩 중...")
                            }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .onAppear {
                                print("[ProfileSectionView] 프로필 이미지 로드 성공")
                            }
                    case .failure(let error):
                        Image("profile_empty")
                            .resizable()
                            .scaledToFill()
                            .onAppear {
                                print("[ProfileSectionView] 프로필 이미지 로드 실패: \(error)")
                            }
                    @unknown default:
                        Image("profile_empty")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 127, height: 127)
                .clipShape(Circle())
            } else {
                Image("profile_empty")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 127, height: 127)
                    .clipShape(Circle())
                    .onAppear {
                        print("[ProfileSectionView] 프로필 이미지 없음 (기본 이미지 표시)")
                    }
            }
        }
    }
}
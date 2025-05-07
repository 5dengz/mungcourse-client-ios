import SwiftUI

struct BasicInfoView: View {
    @EnvironmentObject var dogVM: DogViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
            if let detail = dogVM.dogDetail {
                HStack {
                    Text("견종/성별")
                    Spacer()
                    Text("\(detail.breed)/\(detail.gender)")
                }
                Divider()
                    .background(Color("gray300"))
                    .padding(.bottom, 0)
                HStack {
                    Text("생년월일")
                    Spacer()
                    Text(detail.birthDate)
                }
                Divider()
                    .background(Color("gray300"))
                    .padding(.bottom, 0)
                HStack {
                    Text("체중")
                    Spacer()
                    Text("\(detail.weight, specifier: "%.1f")kg")
                }
                Divider()
                    .background(Color("gray300"))
                    .padding(.bottom, 0)
                HStack {
                    Text("중성화 여부")
                    Spacer()
                    Text(detail.neutered ? "예" : "아니오")
                }
                Divider()
                    .background(Color("gray300"))
                    .padding(.bottom, 0)
                HStack {
                    Text("슬개골 탈골 수술 여부")
                    Spacer()
                    Text(detail.hasArthritis ? "예" : "아니오")
                }
            } else if let error = dogVM.dogDetailError {
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 40))
                        .padding(.bottom, 8)
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            }
        }
            }
            .font(.custom("Pretendard-Regular", size: 14))
            .padding()
            .background(Color("pointwhite"))
    }
}

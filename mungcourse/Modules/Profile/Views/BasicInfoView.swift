import SwiftUI

struct BasicInfoView: View {
    @EnvironmentObject var dogVM: DogViewModel

    var body: some View {
        VStack(spacing: 0) {
            if let detail = dogVM.dogDetail {
                HStack {
                    Text("견종/성별")
                    Spacer()
                    Text("\(detail.breed)/\(detail.gender)")
                }
                Divider()
                HStack {
                    Text("생년월일")
                    Spacer()
                    Text(detail.birthDate)
                }
                Divider()
                HStack {
                    Text("체중")
                    Spacer()
                    Text("\(detail.weight, specifier: "%.1f")kg")
                }
                Divider()
                HStack {
                    Text("중성화 여부")
                    Spacer()
                    Text(detail.neutered ? "예" : "아니오")
                }
                Divider()
                HStack {
                    Text("슬개골 탈골 수술 여부")
                    Spacer()
                    Text(detail.hasArthritis ? "예" : "아니오")
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            }
        }
        .padding()
        .background(Color.white)
    }
}

#if DEBUG
struct BasicInfoView_Previews: PreviewProvider {
    static var previews: some View {
        BasicInfoView()
            .environmentObject(DogViewModel())
    }
}
#endif 
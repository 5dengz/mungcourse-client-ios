import SwiftUI

struct BasicInfoView: View {
    @EnvironmentObject var dogVM: DogViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("견종/성별")
                Spacer()
                Text("말티즈/여아")
            }
            Divider()
            HStack {
                Text("생년월일")
                Spacer()
                Text("2012.04.03")
            }
            Divider()
            HStack {
                Text("체중")
                Spacer()
                Text("3.2kg")
            }
            Divider()
            HStack {
                Text("중성화 여부")
                Spacer()
                Text("예")
            }
            Divider()
            HStack {
                Text("슬개골 탈골 수술 여부")
                Spacer()
                Text("예")
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
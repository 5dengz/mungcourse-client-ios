import SwiftUI

struct WalkRecordView: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("산책 횟수")
                Spacer()
                Text("12번")
            }
            Divider()
            HStack {
                Text("총 거리")
                Spacer()
                Text("2.5km")
            }
            Divider()
            HStack {
                Text("총 소요시간")
                Spacer()
                Text("34분")
            }
            Divider()
            HStack {
                Text("칼로리")
                Spacer()
                Text("3243kcal")
            }
        }
        .padding()
        .background(Color.white)
    }
}

#if DEBUG
struct WalkRecordView_Previews: PreviewProvider {
    static var previews: some View {
        WalkRecordView()
    }
}
#endif 
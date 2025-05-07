import SwiftUI
import struct Combine.Published
import Combine
// DogViewModel 및 WalkRecordData 사용
struct WalkRecordView: View {
    @EnvironmentObject var dogVM: DogViewModel
    var body: some View {
        // 집계값 계산
        let count = dogVM.walkRecords.count
        let totalDistance = dogVM.walkRecords.map { $0.distanceKm }.reduce(0, +)
        let totalDurationSec = dogVM.walkRecords.map { $0.durationSec }.reduce(0, +)
        let totalDurationMin = totalDurationSec / 60
        let totalCalories = dogVM.walkRecords.map { $0.calories }.reduce(0, +)

        ScrollView {
            VStack(spacing: 15) {
            HStack {
                Text("산책 횟수")
                Spacer()
                Text("\(count)번")
            }
            Divider()
                .background(Color("gray300"))
                .padding(.bottom, 0)
            HStack {
                Text("총 거리")
                Spacer()
                Text("\(totalDistance, specifier: "%.1f")km")
            }
            Divider()
                .background(Color("gray300"))
                .padding(.bottom, 0)
            HStack {
                Text("총 소요시간")
                Spacer()
                Text("\(totalDurationMin)분")
            }
            Divider()
                .background(Color("gray300"))
                .padding(.bottom, 0)
            HStack {
                Text("칼로리")
                Spacer()
                Text("\(totalCalories)kcal")
            }
            }
            .font(.custom("Pretendard-Regular", size: 14))
            .padding()
            .background(Color("pointwhite"))
        }
        .onAppear {
            if let dogId = dogVM.selectedDog?.id {
                Task {
                    await dogVM.fetchWalkRecords(dogId)
                }
            }
        }
    }
}

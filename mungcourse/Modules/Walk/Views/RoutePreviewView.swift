import SwiftUI
import NMapsMap

struct RoutePreviewView: View {
    let coordinates: [NMGLatLng]
    let distance: Double
    let estimatedTime: Int
    let waypoints: [DogPlace]
    @Environment(\.dismiss) private var dismiss
    @State private var goToStartWalk = false

    var body: some View {
        VStack(spacing: 0) {
            SimpleNaverMapView(
                coordinates: coordinates,
                boundingBox: nil,
                pathColor: UIColor(named: "main") ?? .systemBlue,
                pathWidth: 5
            )
            .frame(height: 350)
            .edgesIgnoringSafeArea(.top)

            VStack(spacing: 16) {
                Text("총 거리: \(Int(distance))m  |  예상 소요: \(estimatedTime)분")
                    .font(.headline)
                    .padding(.top, 16)

                if !waypoints.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(waypoints, id: \.id) { place in
                            Text(place.name)
                                .font(.caption)
                                .padding(8)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(8)
                        }
                    }
                }

                Spacer()

                NavigationLink(destination: StartWalkView(routeOption: RouteOption(type: .recommended, totalDistance: distance, estimatedTime: estimatedTime, waypoints: waypoints, coordinates: coordinates)), isActive: $goToStartWalk) {
                    EmptyView()
                }

                Button(action: { goToStartWalk = true }) {
                    Text("이 코스로 산책 시작")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("main"))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitle("추천 경로 미리보기", displayMode: .inline)
        .navigationBarBackButtonHidden(false)
        .background(Color(.systemGroupedBackground))
    }
}

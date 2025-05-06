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
        ZStack(alignment: .bottom) {
            SimpleNaverMapView(
                coordinates: coordinates,
                boundingBox: nil,
                pathColor: UIColor(named: "main") ?? .systemBlue,
                pathWidth: 5
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: [.leading, .trailing, .bottom])
            .layoutPriority(1)

            VStack(spacing: 0) {
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
                .padding(.horizontal, 36)
                .padding(.vertical, 16)
            }
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .bottom)
            .background(Color.white)
        }
        .navigationBarTitle("추천 경로 미리보기", displayMode: .inline)
        .navigationBarBackButtonHidden(false)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
    }
}

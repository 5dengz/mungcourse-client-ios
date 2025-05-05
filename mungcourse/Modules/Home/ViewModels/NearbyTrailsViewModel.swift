import Foundation
import Combine
import CoreLocation
import SwiftUI

// MARK: - NearbyTrailsViewModel (위치 변경 감지 및 데이터 fetch)
class NearbyTrailsViewModel: ObservableObject {
    @Published var dogPlaces: [DogPlace] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var cancellables = Set<AnyCancellable>()

    // 위치 변경 자동 구독 로직 제거
    init() {
        // 앱이 처음 켜지거나 홈 화면으로 돌아올 때만 데이터 로드
    }

    func fetchNearbyDogPlaces(category: String? = nil) {
        print("[NearbyTrailsViewModel] fetchNearbyDogPlaces 호출, category=\(category ?? "nil")")
        guard let location = GlobalLocationManager.shared.lastLocation else {
            print("[NearbyTrailsViewModel] 위치 정보 없음 (lastLocation == nil)")
            self.errorMessage = "위치 정보를 가져올 수 없습니다."
            return
        }
        print("[NearbyTrailsViewModel] 현재 위치 lat=\(location.coordinate.latitude), lng=\(location.coordinate.longitude)")
        isLoading = true
        errorMessage = nil

        DogPlaceService.shared.fetchDogPlaces(
            currentLat: location.coordinate.latitude,
            currentLng: location.coordinate.longitude,
            category: category
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let places):
                    print("[NearbyTrailsViewModel] 장소 데이터 fetch 성공, count=\(places.count)")
                    self?.dogPlaces = places
                    self?.isLoading = false
                case .failure(let error):
                    print("[NearbyTrailsViewModel] 장소 데이터 fetch 실패: \(error.localizedDescription)")
                    self?.errorMessage = "장소 정보를 불러오지 못했습니다."
                    self?.isLoading = false
                }
            }
        }
    }
}

import Foundation
import Combine
import SwiftUI
import CoreLocation

class SelectWaypointViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var dogPlaces: [DogPlace] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var selectedPlaceIds: Set<Int> = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Add debounce to search text to avoid too many API calls
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { !$0.isEmpty && $0.count >= 1 }
            .sink { [weak self] query in
                self?.searchDogPlaces(query: query)
            }
            .store(in: &cancellables)
    }
    
    func searchDogPlaces(query: String) {
        guard !query.isEmpty else {
            dogPlaces = []
            return
        }
        
        guard let location = GlobalLocationManager.shared.lastLocation else {
            self.errorMessage = nil
            let defaultLat = 37.5666103
            let defaultLng = 126.9783882
            
            performSearch(query: query, latitude: defaultLat, longitude: defaultLng)
            return
        }
        
        performSearch(query: query, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    private func performSearch(query: String, latitude: Double, longitude: Double) {
        isLoading = true
        errorMessage = nil
        
        DogPlaceService.shared.searchDogPlaces(
            currentLat: latitude,
            currentLng: longitude,
            placeName: query
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let places):
                    self?.dogPlaces = places
                    self?.errorMessage = nil
                case .failure(let error):
                    print("검색 오류 발생: \(error.localizedDescription)")
                    self?.dogPlaces = []
                    self?.errorMessage = nil
                }
            }
        }
    }
    
    func clearSearch() {
        searchText = ""
        dogPlaces = []
        errorMessage = nil
        // 검색 초기화 시 선택 상태도 초기화
        selectedPlaceIds.removeAll()
    }
    
    func toggleSelection(for placeId: Int) {
        if selectedPlaceIds.contains(placeId) {
            selectedPlaceIds.remove(placeId)
        } else {
            selectedPlaceIds.insert(placeId)
        }
    }
    
    func isSelected(_ placeId: Int) -> Bool {
        return selectedPlaceIds.contains(placeId)
    }
    
    // 선택 완료 버튼 활성화 여부
    var isCompleteButtonEnabled: Bool {
        return !selectedPlaceIds.isEmpty
    }
    
    // 선택된 장소들 가져오기
    func getSelectedPlaces() -> [DogPlace] {
        return dogPlaces.filter { selectedPlaceIds.contains($0.id) }
    }
    
    // 현재 위치 가져오기
    func getCurrentLocation() -> CLLocationCoordinate2D? {
        if let location = GlobalLocationManager.shared.lastLocation {
            return CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
        // 기본 좌표 (서울 시청)
        return CLLocationCoordinate2D(latitude: 37.5666103, longitude: 126.9783882)
    }
}
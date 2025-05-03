import Foundation
import Combine
import SwiftUI
import CoreLocation

class SelectWaypointViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var dogPlaces: [DogPlace] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Add debounce to search text to avoid too many API calls
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
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
            self.errorMessage = "현재 위치를 찾을 수 없습니다."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        DogPlaceService.shared.searchDogPlaces(
            currentLat: location.coordinate.latitude,
            currentLng: location.coordinate.longitude,
            placeName: query
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let places):
                    self?.dogPlaces = places
                    if places.isEmpty {
                        self?.errorMessage = "검색 결과가 없습니다."
                    }
                case .failure(let error):
                    self?.errorMessage = "검색 중 오류가 발생했습니다: \(error.localizedDescription)"
                    self?.dogPlaces = []
                }
            }
        }
    }
    
    func clearSearch() {
        searchText = ""
        dogPlaces = []
        errorMessage = nil
    }
} 
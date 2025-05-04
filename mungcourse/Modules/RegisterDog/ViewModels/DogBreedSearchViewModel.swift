import Foundation
import Combine
import SwiftUI

class DogBreedSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var filteredBreeds: [String] = []
    @Published var selectedBreed: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.searchBreeds(query: query)
            }
            .store(in: &cancellables)
        
        // 초기 상태는 모든 견종 표시
        self.filteredBreeds = DogBreeds.all
    }
    
    func searchBreeds(query: String) {
        if query.isEmpty {
            filteredBreeds = DogBreeds.all
            return
        }
        
        filteredBreeds = DogBreeds.all.filter { $0.lowercased().contains(query.lowercased()) }
    }
    
    func clearSearch() {
        searchText = ""
        filteredBreeds = DogBreeds.all
    }
    
    func selectBreed(_ breed: String) {
        selectedBreed = breed
    }
}
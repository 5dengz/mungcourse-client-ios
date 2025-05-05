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
        
        // 초기 상태는 빈 결과 목록 (검색 시에만 결과 표시)
        self.filteredBreeds = []
    }
    
    func searchBreeds(query: String) {
        if query.isEmpty {
            // 검색어가 비었을 때는 결과를 비움
            filteredBreeds = []
            return
        }
        
        filteredBreeds = DogBreeds.all.filter { $0.lowercased().contains(query.lowercased()) }
    }
    
    func clearSearch() {
        searchText = ""
        filteredBreeds = []
    }
    
    func selectBreed(_ breed: String) {
        selectedBreed = breed
    }
}
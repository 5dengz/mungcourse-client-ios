import Foundation
import Combine

@MainActor
class DogViewModel: ObservableObject {
    @Published var dogs: [Dog] = []
    @Published var mainDog: Dog? = nil
    @Published var selectedDog: Dog? = nil
    @Published var selectedDogName: String = ""

    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchDogs()
    }

    func fetchDogs() {
        DogService.shared.fetchDogs()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    print("[DogViewModel] fetchDogs error: \(error)")
                }
            } receiveValue: { [weak self] dogs in
                self?.dogs = dogs
                if let main = dogs.first(where: { $0.isMain }) {
                    self?.mainDog = main
                    self?.selectedDog = main
                    self?.selectedDogName = main.name
                }
            }
            .store(in: &cancellables)
    }

    func selectDog(_ dog: Dog) {
        selectedDog = dog
        selectedDogName = dog.name
    }

    var dogNames: [String] {
        dogs.map { $0.name }
    }
} 
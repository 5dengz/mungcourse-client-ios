import Foundation
import Combine

@MainActor
class DogViewModel: ObservableObject {
    @Published var dogs: [Dog] = []
    @Published var mainDog: Dog? = nil
    @Published var selectedDog: Dog? = nil
    @Published var selectedDogName: String = ""
    @Published var dogDetail: DogRegistrationResponseData? = nil
    @Published var walkRecords: [WalkRecordData] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchDogs()
        NotificationCenter.default.addObserver(forName: .appDataDidReset, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in
                self?.reset()
            }
        }
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
        walkRecords = []
    }

    var dogNames: [String] {
        dogs.map { $0.name }
    }

    func fetchDogDetail(_ dogId: Int) async {
        do {
            let detail = try await DogService.shared.fetchDogDetail(dogId: dogId)
            self.dogDetail = detail
        } catch {
            print("[DogViewModel] fetchDogDetail error: \(error)")
        }
    }

    func fetchWalkRecords(_ dogId: Int) async {
        do {
            let records = try await DogService.shared.fetchWalkRecords(dogId: dogId)
            self.walkRecords = records
        } catch {
            print("[DogViewModel] fetchWalkRecords error: \(error)")
        }
    }

    /// 모든 상태를 초기화 (로그아웃/탈퇴 시 호출)
    func reset() {
        dogs = []
        mainDog = nil
        selectedDog = nil
        selectedDogName = ""
        dogDetail = nil
        walkRecords = []
    }
}
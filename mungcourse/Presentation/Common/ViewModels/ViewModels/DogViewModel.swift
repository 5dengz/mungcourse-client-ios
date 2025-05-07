import Foundation
import Combine

@MainActor
class DogViewModel: ObservableObject {
    @Published var dogs: [Dog] = []
    @Published var mainDog: Dog? = nil
    @Published var selectedDog: Dog? = nil
    @Published var selectedDogName: String = ""
    @Published var dogDetail: DogRegistrationResponseData? = nil
    @Published var dogDetailError: String? = nil
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

    func fetchDogs(completion: (() -> Void)? = nil) {
        DogService.shared.fetchDogs()
            .receive(on: DispatchQueue.main)
            .sink { completionState in
                if case let .failure(error) = completionState {
                    print("[DogViewModel] fetchDogs error: \(error)")
                }
            } receiveValue: { [weak self] dogs in
                self?.dogs = dogs
                if let main = dogs.first(where: { $0.isMain }) {
                    self?.mainDog = main
                    self?.selectedDog = main
                    self?.selectedDogName = main.name
                }
                completion?()
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
            var detail = try await DogService.shared.fetchDogDetail(dogId: dogId)
            // 서버에서 id가 누락될 경우를 대비해 mainDog의 id를 강제로 할당
            if detail.id != dogId {
                detail = DogRegistrationResponseData(
                    id: dogId,
                    name: detail.name,
                    gender: detail.gender,
                    breed: detail.breed,
                    birthDate: detail.birthDate,
                    weight: detail.weight,
                    postedAt: detail.postedAt,
                    hasArthritis: detail.hasArthritis,
                    neutered: detail.neutered,
                    dogImgUrl: detail.dogImgUrl,
                    isMain: detail.isMain
                )
            }
            self.dogDetail = detail
            self.dogDetailError = nil
        } catch {
            print("[DogViewModel] fetchDogDetail error: \(error)")
            self.dogDetail = nil
            self.dogDetailError = "반려견 정보를 불러올 수 없습니다.\n네트워크 상태를 확인하거나, 잠시 후 다시 시도해주세요."
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
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
        Task {
            do {
                // 먼저 메인 강아지를 가져온 후, 모든 강아지 목록 가져오기
                try await fetchMainDog()
                fetchDogs()
            } catch {
                print("[DogViewModel] Init error: \(error)")
                // 메인 강아지 가져오기 실패 시 모든 강아지 목록만 가져오기
                fetchDogs()
            }
        }
        
        NotificationCenter.default.addObserver(forName: .appDataDidReset, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in
                self?.reset()
            }
        }
    }

    // 모든 강아지 목록 가져오기
    func fetchDogs(completion: (() -> Void)? = nil) {
        DogService.shared.fetchDogs()
            .receive(on: DispatchQueue.main)
            .sink { completionState in
                if case let .failure(error) = completionState {
                    print("[DogViewModel] fetchDogs error: \(error)")
                }
            } receiveValue: { [weak self] dogs in
                self?.dogs = dogs
                
                // mainDog가 없는 경우에만 dogs 배열에서 isMain=true인 강아지를 찾아서 설정
                if self?.mainDog == nil, let main = dogs.first(where: { $0.isMain }) {
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

    /// 메인 강아지 가져오기
    func fetchMainDog() async throws {
        do {
            // @MainActor에서 직접 Combine 퍼블리셔를 async/await로 변환
            let main = try await withCheckedThrowingContinuation { continuation in
                DogService.shared.fetchMainDog()
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                continuation.resume(throwing: error)
                            }
                        },
                        receiveValue: { dog in
                            continuation.resume(returning: dog)
                        }
                    )
                    .store(in: &self.cancellables)
            }
            
            self.mainDog = main
            self.selectedDog = main
            self.selectedDogName = main.name
            print("[DogViewModel] 메인 강아지 가져오기 성공: \(main.name)")
        } catch {
            print("[DogViewModel] fetchMainDog error: \(error)")
            throw error
        }
    }
    
    /// 대표 강아지 설정
    func setMainDog(_ dogId: Int) async -> Bool {
        do {
            print("[DogViewModel] 대표 강아지 설정 API 호출 시작 (dogId: \(dogId))")
            let mainDogResult = try await DogService.shared.setMainDog(dogId: dogId)
            print("[DogViewModel] 대표 강아지 설정 API 성공: \(mainDogResult.name)")
            
            // API 호출이 성공했을 때만 대표 강아지 변경
            self.mainDog = mainDogResult
            self.selectedDog = mainDogResult
            self.selectedDogName = mainDogResult.name
            
            // 모든 강아지의 isMain 상태 업데이트
            let updatedDogs = self.dogs.map { dog -> Dog in
                return Dog(
                    id: dog.id,
                    name: dog.name,
                    dogImgUrl: dog.dogImgUrl,
                    isMain: dog.id == dogId
                )
            }
            
            self.dogs = updatedDogs
            print("[DogViewModel] 강아지 목록 isMain 업데이트 완료, 총 \(updatedDogs.count)개")
            
            // 경우에 따라 fetchMainDog() 호출해서 다시 서버에서 가져오기
            // Try to re-fetch to ensure consistency
            try? await fetchMainDog()
            
            return true
        } catch {
            print("[DogViewModel] 대표 강아지 설정 실패: \(error)")
            return false
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
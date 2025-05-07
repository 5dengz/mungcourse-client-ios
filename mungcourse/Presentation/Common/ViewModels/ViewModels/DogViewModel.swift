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
                guard let self = self else { return }
                self.dogs = dogs
                print("[DogViewModel] fetchDogs 성공: \(dogs.count)개 강아지 가져옴")
                
                // mainDog 상태 관리 개선
                if let mainDog = self.mainDog {
                    // 1. 현재 mainDog가 dogs 목록에 있는지 확인 (삭제되었는지 확인)
                    let mainDogExists = dogs.contains(where: { $0.id == mainDog.id })
                    print("[DogViewModel] 현재 mainDog(id=\(mainDog.id)) 존재 여부: \(mainDogExists)")
                    
                    if !mainDogExists {
                        // 현재 mainDog가 삭제되었으므로 새로운 mainDog 설정 필요
                        if let serverMain = dogs.first(where: { $0.isMain }) {
                            // 서버에서 지정한 대표 강아지가 있으므로 이를 사용
                            print("[DogViewModel] 서버 지정 대표 강아지 발견: \(serverMain.name)")
                            self.mainDog = serverMain
                            self.selectedDog = serverMain
                            self.selectedDogName = serverMain.name
                        } else if let first = dogs.first {
                            // 서버에 대표 강아지가 없으므로 첫 번째 강아지를 대표로 설정
                            print("[DogViewModel] 서버 지정 대표 강아지 없음. 첫 번째 강아지를 대표로 설정: \(first.name)")
                            Task {
                                // 서버에도 대표 강아지 설정 요청
                                await self.setMainDog(first.id)
                            }
                        } else {
                            // 강아지가 없음 - 모든 강아지 관련 상태 초기화
                            print("[DogViewModel] 모든 강아지가 삭제됨. 상태 초기화")
                            self.mainDog = nil
                            self.selectedDog = nil
                            self.selectedDogName = ""
                        }
                    } else {
                        // mainDog는 존재하지만 정보가 추가 업데이트 되었을 수 있으므로 갱신
                        if let updatedMainDog = dogs.first(where: { $0.id == mainDog.id }) {
                            // 같은 ID를 가진 강아지의 최신 정보로 업데이트
                            if updatedMainDog.name != mainDog.name || updatedMainDog.dogImgUrl != mainDog.dogImgUrl {
                                print("[DogViewModel] mainDog 정보 갱신: \(mainDog.name) -> \(updatedMainDog.name)")
                                self.mainDog = updatedMainDog
                                self.selectedDog = updatedMainDog
                                self.selectedDogName = updatedMainDog.name
                            }
                        }
                    }
                } else if let serverMain = dogs.first(where: { $0.isMain }) {
                    // mainDog가 없지만 서버에 지정된 대표 강아지가 있는 경우
                    print("[DogViewModel] mainDog 없음. 서버 지정 mainDog 사용: \(serverMain.name)")
                    self.mainDog = serverMain
                    self.selectedDog = serverMain
                    self.selectedDogName = serverMain.name
                } else if let first = dogs.first {
                    // 서버에 대표 강아지가 없으므로 첫 번째 강아지를 대표로 설정
                    print("[DogViewModel] mainDog 없음. 첫 번째 강아지를 mainDog로 설정: \(first.name)")
                    Task {
                        await self.setMainDog(first.id)
                    }
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
import Foundation
import Combine

// ViewModel for RoutineSettingsView
class RoutineViewModel: ObservableObject {
    @Published var routines: [Routine] = []
    @Published var selectedDay: DayOfWeek = .today
    @Published var showAddRoutine: Bool = false
    @Published var editingRoutine: Routine? = nil

    private var cancellables = Set<AnyCancellable>()
    
    // 중복 토글 방지를 위한 처리 중인 루틴 ID 추적
    private var togglingRoutineIds = Set<Int>()
    
    // 로딩 상태 추적 (UI에서 사용 가능)
    @Published var loadingRoutineIds = Set<Int>()
    @Published var isLoadingRoutines = false

    init() {
        fetchRoutines(for: selectedDay)
        $selectedDay
            .sink { [weak self] day in
                self?.fetchRoutines(for: day)
            }
            .store(in: &cancellables)
    }

    func fetchRoutines(for day: DayOfWeek) {
        let dateStr = dateString(for: day)
        print("[RoutineViewModel] Fetching routines for date: \(dateStr)")
        
        isLoadingRoutines = true
        
        RoutineService.shared.fetchRoutines(date: dateStr)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoadingRoutines = false
                if case .failure(let error) = completion {
                    print("Error fetching routines: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] dataList in
                self?.isLoadingRoutines = false
                print("[RoutineViewModel] Received \(dataList.count) routines from server")
                dataList.forEach { data in
                    print("  - Routine: \(data.name), routineId: \(data.routineId), routineCheckId: \(data.routineCheckId), isCompleted: \(data.isCompleted)")
                }
                
                self?.routines = dataList.map {
                    Routine(routineId: $0.routineId,
                            routineCheckId: $0.routineCheckId,
                            title: $0.name,
                            time: $0.alarmTime,
                            isDone: $0.isCompleted,
                            days: [day])
                }
            })
            .store(in: &cancellables)
    }

    private func dateString(for day: DayOfWeek) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else {
            return ""
        }
        let dates = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
        if let index = DayOfWeek.allCases.firstIndex(of: day), index < dates.count {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: dates[index])
        }
        return ""
    }

    func toggleRoutineCompletion(routine: Routine) {
        let timestamp = DateFormatter().string(from: Date())
        print("[RoutineViewModel] [\(timestamp)] toggleRoutineCompletion CALLED for: \(routine.title), routineCheckId: \(routine.routineCheckId)")
        
        // 이미 처리 중인 루틴인지 확인
        guard !togglingRoutineIds.contains(routine.routineCheckId) else {
            print("[RoutineViewModel] ❌ Toggle already in progress for routineCheckId: \(routine.routineCheckId)")
            return
        }
        
        print("[RoutineViewModel] ✅ Starting toggle for routine: \(routine.title), routineCheckId: \(routine.routineCheckId), current state: \(routine.isDone)")
        
        // 처리 중으로 표시
        togglingRoutineIds.insert(routine.routineCheckId)
        print("[RoutineViewModel] 🔄 Added routineCheckId \(routine.routineCheckId) to togglingRoutineIds. Current set: \(togglingRoutineIds)")
        
        RoutineService.shared.toggleRoutineCheck(routineCheckId: routine.routineCheckId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                // 처리 완료 후 제거
                self?.togglingRoutineIds.remove(routine.routineCheckId)
                print("[RoutineViewModel] 🔄 Removed routineCheckId \(routine.routineCheckId) from togglingRoutineIds")
                
                if case .failure(let error) = completion {
                    print("[RoutineViewModel] ❌ Toggle failed: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] toggleResponse in
                print("[RoutineViewModel] ✅ Toggle success from server: routineCheckId=\(toggleResponse.routineCheckId), isCompleted=\(toggleResponse.isCompleted)")
                
                // 서버 응답으로 UI 상태 업데이트
                if let index = self?.routines.firstIndex(where: { $0.routineCheckId == routine.routineCheckId }) {
                    let oldState = self?.routines[index].isDone
                    self?.routines[index].isDone = toggleResponse.isCompleted
                    print("[RoutineViewModel] 🔄 Updated local state: routineCheckId=\(routine.routineCheckId), old=\(oldState ?? false), new=\(toggleResponse.isCompleted)")
                } else {
                    print("[RoutineViewModel] ⚠️ Could not find routine with routineCheckId=\(routine.routineCheckId) in local array")
                }
                
                // 즉시 서버 상태 검증을 위한 GET 요청 (서버 DB 업데이트 시간 고려하여 2초로 연장)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self?.verifyServerState(routineCheckId: routine.routineCheckId, expectedState: toggleResponse.isCompleted)
                }
            })
            .store(in: &cancellables)
    }

    /// 토글 후 서버 상태 즉시 검증 (재시도 로직 포함)
    private func verifyServerState(routineCheckId: Int, expectedState: Bool, retryCount: Int = 0) {
        let maxRetries = 3
        print("[RoutineViewModel] 🔍 Verifying server state for routineCheckId: \(routineCheckId), expected: \(expectedState), attempt: \(retryCount + 1)/\(maxRetries + 1)")
        
        // 현재 선택된 날짜로 검증 요청 (오늘 날짜가 아닌 selectedDay 사용)
        let currentDateString = dateString(for: selectedDay)
        print("[RoutineViewModel] 🔍 Verification request for date: \(currentDateString) (selectedDay: \(selectedDay))")
        print("[RoutineViewModel] 🔍 Looking for routineCheckId: \(routineCheckId) in server response...")
        
        RoutineService.shared.fetchRoutines(date: currentDateString)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("[RoutineViewModel] ❌ Failed to verify server state: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] routinesFromServer in
                print("[RoutineViewModel] 🔍 Server verification response contains \(routinesFromServer.count) routines:")
                routinesFromServer.forEach { routine in
                    print("[RoutineViewModel] 🔍   - routineCheckId: \(routine.routineCheckId), name: \(routine.name), date: \(routine.date), isCompleted: \(routine.isCompleted)")
                }
                
                if let serverRoutine = routinesFromServer.first(where: { $0.routineCheckId == routineCheckId }) {
                    print("[RoutineViewModel] 🔍 ✅ Found target routine! routineCheckId=\(routineCheckId), server_isCompleted=\(serverRoutine.isCompleted), expected=\(expectedState)")
                    
                    if serverRoutine.isCompleted != expectedState {
                        print("[RoutineViewModel] ⚠️ SERVER STATE MISMATCH! routineCheckId=\(routineCheckId), server=\(serverRoutine.isCompleted), expected=\(expectedState)")
                        
                        // 재시도 로직
                        if retryCount < maxRetries {
                            let retryDelay = Double(retryCount + 1) * 1.0 // 1초, 2초, 3초 간격으로 재시도
                            print("[RoutineViewModel] 🔄 Retrying verification in \(retryDelay) seconds... (attempt \(retryCount + 2)/\(maxRetries + 1))")
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                                self?.verifyServerState(routineCheckId: routineCheckId, expectedState: expectedState, retryCount: retryCount + 1)
                            }
                        } else {
                            print("[RoutineViewModel] ⚠️ Max retries reached. SERVER INCONSISTENCY DETECTED!")
                            print("[RoutineViewModel] ⚠️ Toggle API returned: \(expectedState), but Query API consistently returns: \(serverRoutine.isCompleted)")
                            print("[RoutineViewModel] 🤔 This indicates a server-side issue (DB inconsistency, caching, or different data sources)")
                            
                            // 서버 불일치 상황에서는 토글 API 응답을 신뢰하고 클라이언트 상태 유지
                            print("[RoutineViewModel] 🎯 Keeping client state as per Toggle API response: \(expectedState)")
                            print("[RoutineViewModel] 📝 Server team should investigate DB/API inconsistency for routineCheckId: \(routineCheckId)")
                        }
                    } else {
                        print("[RoutineViewModel] ✅ Server state matches expected state")
                    }
                } else {
                    print("[RoutineViewModel] ❌ CRITICAL: routineCheckId=\(routineCheckId) NOT FOUND in server response!")
                    print("[RoutineViewModel] ❌ Available routineCheckIds: \(routinesFromServer.map { $0.routineCheckId })")
                    print("[RoutineViewModel] ❌ Request date: \(currentDateString), selectedDay: \(self?.selectedDay ?? .today)")
                    
                    // 루틴이 응답에 없는 경우에도 재시도 시도
                    if retryCount < maxRetries {
                        let retryDelay = Double(retryCount + 1) * 1.0
                        print("[RoutineViewModel] 🔄 Retrying to find missing routine in \(retryDelay) seconds... (attempt \(retryCount + 2)/\(maxRetries + 1))")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                            self?.verifyServerState(routineCheckId: routineCheckId, expectedState: expectedState, retryCount: retryCount + 1)
                        }
                    } else {
                        print("[RoutineViewModel] ❌ Max retries reached. Routine \(routineCheckId) still not found in server response.")
                    }
                }
            })
            .store(in: &cancellables)
    }

    func deleteRoutine(_ routine: Routine) {
        RoutineService.shared.deleteRoutine(routineId: routine.routineId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to delete routine:", error)
                }
            }, receiveValue: { [weak self] _ in
                self?.fetchRoutines(for: self?.selectedDay ?? .today)
            })
            .store(in: &cancellables)
    }
}

---

# 멍코스 iOS 앱의 전역 상태 관리 구조 분석

멍코스 iOS 앱은 SwiftUI와 Combine 프레임워크를 기반으로 현대적인 상태 관리 패턴을 구현하고 있습니다. 이 문서에서는 앱의 전역 상태 관리 방식을 집중적으로 분석합니다.

## 1. 핵심 전역 상태 관리 객체

### 1.1. TokenManager

TokenManager는 앱의 인증 상태를 전역적으로 관리하는 싱글톤 객체입니다.

```swift
final class TokenManager: ObservableObject {
    static let shared = TokenManager()
    private let keychain = Keychain(service: "com.mungcourse.app")
    @Published private(set) var accessToken: String?
    @Published private(set) var refreshToken: String?
    
    // 메서드: saveTokens, getAccessToken, getRefreshToken, clearTokens, refreshAccessToken 등
}
```

**특징:**
- 싱글톤 패턴으로 구현되어 앱 전체에서 단일 인스턴스 사용
- `@Published` 프로퍼티를 사용하여 토큰 상태 변화 감지 및 전파
- KeychainAccess 라이브러리를 활용한 안전한 토큰 저장
- 토큰 관련 작업(저장, 조회, 갱신, 삭제)을 중앙 집중화

### 1.2. DogViewModel

DogViewModel은 앱의 핵심 데이터인 반려견 정보를 전역적으로 관리합니다.

```swift
@MainActor
class DogViewModel: ObservableObject {
    @Published var dogs: [Dog] = []
    @Published var mainDog: Dog? = nil
    @Published var selectedDog: Dog? = nil
    @Published var selectedDogName: String = ""
    @Published var dogDetail: DogRegistrationResponseData? = nil
    @Published var walkRecords: [WalkRecordData] = []
    
    // 메서드: fetchDogs, selectDog, fetchDogDetail, fetchWalkRecords, reset 등
}
```

**특징:**
- `@MainActor` 어노테이션을 통해 UI 스레드 안전성 보장
- `@Published` 프로퍼티를 통한 반응형 데이터 관리
- 여러 화면에서 EnvironmentObject로 주입되어 전역적으로 사용
- 앱 전체에서 필요한 반려견 관련 상태와 메서드 중앙화

### 1.3. GlobalLocationManager

위치 정보를 전역적으로 관리하는 싱글톤 객체로, 여러 화면에서 위치 데이터에 접근할 수 있습니다.

```swift
class GlobalLocationManager: NSObject, ObservableObject {
    static let shared = GlobalLocationManager()
    @Published var lastLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus
    
    // 메서드: startUpdatingLocation, stopUpdatingLocation 등
}
```

## 2. 전역 상태 주입 및 사용 패턴

### 2.1. App 진입점에서의 상태 초기화

앱의 진입점인 `mungcourseApp.swift`에서 전역 상태 객체들이 초기화됩니다.

```swift
@main
struct mungcourseApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @StateObject private var tokenManager = TokenManager.shared
    @StateObject private var dogVM = DogViewModel()
    
    // 앱 상태 리셋 처리 등
}
```

이를 통해 앱 생명주기 동안 유지되는 단일 인스턴스가 생성됩니다.

### 2.2. EnvironmentObject를 통한 상태 주입

DogViewModel은 EnvironmentObject를 통해 뷰 계층에 주입됩니다.

```swift
SplashView()
    .environmentObject(dogVM)
    .preferredColorScheme(.light)
```

이후 다양한 화면에서 @EnvironmentObject를 통해 접근:

```swift
struct ProfileTabView: View {
    @EnvironmentObject var dogVM: DogViewModel
    // ...
}
```

### 2.3. 싱글톤 객체의 직접 접근

TokenManager와 같은 싱글톤 객체는 필요한 곳에서 직접 접근하는 패턴을 사용합니다.

```swift
if let token = TokenManager.shared.getAccessToken(), !token.isEmpty {
    // 토큰 기반 로직 처리
}
```

## 3. 상태 변경 감지 및 전파 메커니즘

### 3.1. Combine 기반 반응형 상태 관리

```swift
private var cancellables = Set<AnyCancellable>()

func fetchDogs() {
    DogService.shared.fetchDogs()
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in /* 에러 처리 */ },
            receiveValue: { [weak self] dogs in
                self?.dogs = dogs
                if let main = dogs.first(where: { $0.isMain }) {
                    self?.mainDog = main
                    self?.selectedDog = main
                }
            }
        )
        .store(in: &cancellables)
}
```

### 3.2. 알림 센터를 통한 이벤트 전파

```swift
extension Notification.Name {
    static let appDataDidReset = Notification.Name("appDataDidReset")
    static let forceViewUpdate = Notification.Name("forceViewUpdate")
}

// 알림 발행
NotificationCenter.default.post(name: .appDataDidReset, object: nil)

// 알림 수신
NotificationCenter.default.addObserver(forName: .appDataDidReset, object: nil, queue: .main) { [weak self] _ in
    Task { @MainActor in
        self?.reset()
    }
}
```

### 3.3. @Published와 @AppStorage를 활용한 상태 동기화

```swift
@AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

@Published private(set) var accessToken: String?
```

## 4. 로그인/로그아웃 시 상태 관리

### 4.1. 로그인 시 토큰 및 사용자 상태 설정

```swift
TokenManager.shared.saveTokens(accessToken: accessToken, refreshToken: refreshToken)
```

### 4.2. 로그아웃 시 상태 리셋

```swift
// TokenManager에서 토큰 클리어
func clearTokens() {
    keychain["accessToken"] = nil
    keychain["refreshToken"] = nil
    self.accessToken = nil
    self.refreshToken = nil
}

// DogViewModel에서 데이터 리셋
func reset() {
    dogs = []
    mainDog = nil
    selectedDog = nil
    selectedDogName = ""
    dogDetail = nil
    walkRecords = []
}

// 로그아웃 실행 시
AuthService.shared.logout()
NotificationCenter.default.post(name: .appDataDidReset, object: nil)
```

## 5. 전역 상태의 지속성 관리

### 5.1. 토큰의 안전한 저장

TokenManager는 KeychainAccess를 사용하여 토큰을 안전하게 저장합니다.

```swift
private let keychain = Keychain(service: "com.mungcourse.app")

func saveTokens(accessToken: String, refreshToken: String) {
    keychain["accessToken"] = accessToken
    keychain["refreshToken"] = refreshToken
    self.accessToken = accessToken
    self.refreshToken = refreshToken
}
```

### 5.2. 사용자 설정의 지속적 저장

앱의 설정 및 상태는 @AppStorage를 통해 UserDefaults에 저장됩니다.

```swift
@AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
```

### 5.3. 온보딩 상태 관리

```swift
private func completeOnboarding() {
    hasCompletedOnboarding = true
    UserDefaults.standard.synchronize()
    
    // 상태 변경을 알리기 위한 노티피케이션 발송
    NotificationCenter.default.post(name: UserDefaults.didChangeNotification, object: nil)
}
```

## 6. 요약 및 평가

멍코스 iOS 앱은 현대적인 SwiftUI 및 Combine 기반의 상태 관리 구조를 잘 활용하고 있습니다. 특히 다음 측면에서 강점을 보입니다:

1. **싱글톤과 ObservableObject의 효과적인 조합**: 토큰 관리, 위치 서비스 등에 싱글톤 패턴을 적용하면서도 ObservableObject 프로토콜을 통해 반응형 특성 유지
2. **환경 객체 활용**: 전역 DogViewModel을 EnvironmentObject로 주입하여 깊은 뷰 계층에서도 효율적으로 접근
3. **알림 시스템과 Combine 통합**: 앱의 중요 이벤트(로그아웃, 리셋 등)를 알림 센터를 통해 전파하고 Combine으로 구독
4. **메인 액터 활용**: @MainActor 어노테이션을 통해 UI 스레드 안전성 보장

개선 가능한 영역:
- 일부 비즈니스 로직과 상태 관리 로직이 섞여 있는 부분 분리 고려
- 의존성 주입 패턴을 더 적극적으로 도입하여 테스트 용이성 향상


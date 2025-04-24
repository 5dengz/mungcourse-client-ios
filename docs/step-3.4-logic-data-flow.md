# 3.4 로직·데이터 흐름 분석

## 3.4.1 화면 간 네비게이션 흐름  
- **앱 진입점**  
  - `mungcourseApp`에서 `hasCompletedOnboarding` 플래그에 따라 `OnboardingView` 또는 `ContentView` 로 분기  
- **탭 기반 이동**  
  - `ContentView`의 `TabView`로 5개 주요 화면 탭 구성:  
    - Home (HomeView)  
    - 산책 시작 (StartWalkView)  
    - 루틴 설정 (RoutineSettingsView)  
    - 산책 기록 (WalkHistoryView)  
    - 프로필 (ProfileTabView)  
- **온보딩 페이지**  
  - `OnboardingView` 내부 `TabView`로 페이징 UI 구현  
  - `currentPage` 상태값 변경으로 페이지 전환  
  - 마지막 페이지에서 `hasCompletedOnboarding = true` 설정 후 메인 화면으로 이동  

## 3.4.2 API 호출 및 데이터 파싱 흐름  
- **외부 네트워크 호출 없음**  
  - 현재 버전에서는 REST/API 호출 로직 미구현  
  - 향후 AI 추천, 코스 조회 등 기능 추가 시 `URLSession` 또는 `Combine` 기반 네트워크 레이어 구현 예상  
- **지도 SDK 연동**  
  - `NMFAuthManager`에 Naver Map API 키 설정 (`init()`에서)  
  - `NMapsMap` 프레임워크를 통해 지도 렌더링, 경로 표시  

## 3.4.3 상태 관리 방식 (State, Binding 등)  
- **@AppStorage**  
  - `hasCompletedOnboarding` 영구 저장 (UserDefaults 기반)  
- **@State**  
  - 뷰 내부 로컬 상태 (`currentPage`, `showLoadingScreen`, UI 표시 토글 등)  
- **@StateObject / @ObservedObject**  
  - `StartWalkViewModel`를 `@StateObject`로 생성하여 라이프사이클 관리  
  - ViewModel의 `@Published` 프로퍼티가 변경될 때 뷰 자동 업데이트  
- **@Environment**  
  - `@Environment(\.dismiss)`로 뷰 닫기 처리  
- **Combine 퍼블리셔**  
  - `WalkTrackingService` 의 `@Published` 프로퍼티 (`currentLocation`, `distance`, `duration`, `calories`, `isTracking`)  
  - ViewModel에서 `.sink` 구독 후 로컬 `@Published` 상태 동기화  

## 3.4.4 WalkTrackingService → ViewModel → View 데이터 흐름  
1. **WalkTrackingService**  
   - `CLLocationManager` 델리게이트 콜백으로 위치 업데이트 수신  
   - `walkPath`, `distance`, `duration`, `calories`, `averageSpeed`, `isTracking` 등 상태 계산 후 `@Published` 발행  
2. **StartWalkViewModel**  
   - `walkTrackingService.$currentLocation` 등 각 퍼블리셔 구독  
   - `centerCoordinate`, `pathCoordinates`, `distance`, `duration`, `calories`, `isWalking`, `isPaused` 등 뷰 상태 업데이트  
3. **StartWalkView**  
   - `@StateObject var viewModel`의 `@Published` 값 바인딩  
   - 지도 중심/경로, 표시되는 거리·시간·칼로리 UI에 반영  
   - 사용자 액션 (`startWalk()`, `pauseWalk()` 등) 호출 시 ViewModel을 통해 서비스 제어  

---
위 분석을 통해 주요 UI 흐름과 데이터 흐름, 상태 관리 방식을 정리했습니다.

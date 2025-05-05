## 산책 도중 지도 화면 로직 요약

```
StartWalkView / RouteWalkView
    ↓ (UI 및 ViewModel)
AdvancedNaverMapView
    ↓ (지도 표시, 경로 시각화)
WalkTrackingService
    (실시간 위치 추적, 경로/거리/칼로리 계산)
```

- **StartWalkView**(또는 **RouteWalkView**)는 산책 UI와 상태를 관리하며, 지도 표시를 위해 AdvancedNaverMapView를 사용합니다.
- **AdvancedNaverMapView**는 실시간 위치, 경로, 마커 등 지도 시각화 역할을 하며, ViewModel에서 전달받은 데이터를 바인딩합니다.
- **WalkTrackingService**는 위치 서비스를 통해 사용자의 이동 경로, 거리, 칼로리 등을 계산하고, ViewModel에 실시간 데이터를 제공합니다.

이 구조를 통해 산책 중 실시간 위치 추적 및 경로 시각화가 자연스럽게 연동됩니다.

---

### 2024-05-05 온보딩 반복 노출 문제 해결

- 문제: 앱 첫 실행 후 온보딩을 완료해도, 앱을 재실행하면 온보딩이 또 나오는 현상 발생
- 원인: SplashView에서 온보딩 완료 여부(hasCompletedOnboarding)를 체크하지 않고, 바로 로그인/강아지 등록/홈으로 분기함
- 해결:
    - SplashView에 @AppStorage("hasCompletedOnboarding")를 추가
    - onAppear에서 hasCompletedOnboarding이 false면 OnboardingView를 fullScreenCover로 띄움
    - OnboardingView에서 온보딩 완료 시 hasCompletedOnboarding이 true로 바뀌면 SplashView가 자동으로 온보딩을 닫고 기존 분기(로그인/강아지 등록/홈)로 이동
- 참고: SwiftUI 공식 문서 @AppStorage, fullScreenCover
- 결과: 온보딩은 앱 첫 실행 시 한 번만 노출되고, 이후에는 다시 나오지 않음

---

### 2024-05-05 강아지 등록 후 홈/프로필 정보 미반영 문제 해결

- 문제: 강아지 등록(RegisterDogView) 후 홈/프로필 화면에 강아지 정보가 바로 반영되지 않음
- 원인: RegisterDogView에서 강아지 등록 후 onComplete에서 dogVM.fetchDogs() 호출이 누락되거나, HomeView에서 dismiss 후 fetchDogs가 호출되지 않아 최신 데이터가 반영되지 않음
- 해결:
    - RegisterDogView의 onComplete에서 dogVM.fetchDogs()를 항상 호출하도록 보장
    - HomeView에서 RegisterDogView가 dismiss된 후에도 dogVM.fetchDogs()를 호출하여 데이터 동기화
- 참고: SwiftUI 공식 문서 @EnvironmentObject, @Published, .onChange, .fullScreenCover
- 결과: 강아지 등록 후 홈/프로필 화면에 강아지 정보가 즉시 반영됨

---

### 2024-05-05 프로필에서 반려견 추가 시 기존 정보 복제 문제 해결

- 문제: 프로필에서 '반려견 추가'를 누르면 기존 강아지 정보가 복제되어 별개의 프로필이 만들어짐
- 원인: RegisterDogView를 띄울 때 initialDetail을 넘기는 경우가 있었음
- 해결:
    - DogSelectionView 등에서 '반려견 추가' 버튼이 RegisterDogView를 띄울 때 initialDetail 없이(즉, nil) 호출하도록 보장
    - RegisterDogView가 initialDetail이 nil일 때 빈 폼을 보여주도록 확인
- 참고: SwiftUI 공식 문서 sheet, fullScreenCover, 뷰 초기화 방식
- 결과: '반려견 추가'를 누르면 항상 빈 입력 폼이 나오고, 기존 강아지 정보가 복제되지 않음

---

### 2025-05-05 산책 도중 흡연구역 danger 마커 지도 표시 기능 구현

- 요구: 산책 시작 위치 기준 2km 반경 내 흡연구역을 GET /v1/walks/smokingzone API로 받아, 지도에 pinpoint_danger 마커로 실시간 표시
- 구조 및 구현:
    1. **StartWalkViewModel**
        - @Published var smokingZones: [NMGLatLng] 추가
        - startWalk()에서 fetchSmokingZones(center:) 호출하여 흡연구역 데이터 조회 및 상태로 관리
    2. **AdvancedNaverMapView**
        - @Binding var dangerCoordinates: [NMGLatLng] 추가
        - makeUIView/updateUIView에서 dangerCoordinates 배열의 각 좌표에 pinpoint_danger 마커 표시
    3. **StartWalkView**
        - AdvancedNaverMapView에 dangerCoordinates: $viewModel.smokingZones 바인딩
    4. **리소스**
        - pinpoint_danger.png 마커 이미지 리소스 추가 필요
- 결과: 산책 시작 시점 기준 2km 내 흡연구역이 지도에 danger 마커로 실시간 표시됨

---

### 2025-05-05 StartWalkViewModel에서 fetchSmokingZones 인식 오류(Cannot find in scope) 문제 해결

- 문제: StartWalkViewModel.swift에서 fetchSmokingZones(center:) 호출 시 'Cannot find in scope' 에러 발생
- 원인: fetchSmokingZones(center:) 함수가 클래스 내에 정의되어 있지 않거나, 선언 위치/오타 등으로 스코프 내에서 인식되지 않음
- 해결:
    - StartWalkViewModel 내에 fetchSmokingZones(center:) 메서드를 정확히 추가(또는 오타/위치 수정)
    - 함수 구현 예시는 아래 참고
```swift
// MARK: - 흡연구역 조회 (2km 반경)
func fetchSmokingZones(center: NMGLatLng) {
    let urlString = "https://your.api.server/v1/walks/smokingzone?lat=\(center.lat)&lng=\(center.lng)&radius=2000"
    guard let url = URL(string: urlString) else { return }
    URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
        guard let self = self, let data = data, error == nil else { return }
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Double]]
            let zones = json?.compactMap { dict -> NMGLatLng? in
                guard let lat = dict["lat"], let lng = dict["lng"] else { return nil }
                return NMGLatLng(lat: lat, lng: lng)
            } ?? []
            DispatchQueue.main.async {
                self.smokingZones = zones
            }
        } catch {
            print("흡연구역 파싱 실패: \(error)")
        }
    }.resume()
}
```
- 참고: Swift 공식 문서 메서드 선언 및 클래스 내 스코프 규칙
- 결과: 함수 선언이 정상적으로 추가되어 에러 없이 빌드 및 실행 가능

---

### 2025-05-05 산책 기록 저장 API 연동 개선

- 문제: 산책 완료 후 산책 데이터를 서버에 저장하는 API 호출 코드가 ViewModel에 직접 포함되어 있어 관심사 분리가 미흡함
- 원인: WalkService에 산책 기록 저장 API가 구현되어 있지 않고, StartWalkViewModel이 직접 API 통신을 담당함
- 해결:
    - WalkService.swift에 uploadWalkSession 메서드를 추가하여 산책 기록 저장 API 기능 구현
    - StartWalkViewModel의 uploadWalkSession 메서드를 수정하여 직접 API 호출 대신 WalkService 사용
    - Combine 프레임워크를 활용하여 비동기 처리 및 통신 결과 핸들링
- 참고: SwiftUI 공식 문서 Combine, AnyPublisher, Future/Promise 패턴
- 결과: 
    - 코드의 관심사가 명확히 분리되어 유지보수성 향상
    - API 통신 로직이 WalkService에 집중되어 재사용성 개선
    - API 변경 시 WalkService만 수정하면 되어 코드 유지관리 용이



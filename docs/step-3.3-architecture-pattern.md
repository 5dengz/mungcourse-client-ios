# 3.3 아키텍처·디자인 패턴 식별

## 사용 기술 스택  
- SwiftUI (UI 선언형)  
- Combine (반응형 바인딩)  
- NMapsMap (지도 렌더링)  
- CoreLocation (위치 업데이트)

## 3.3.1 MVVM (Model–View–ViewModel)  
- **View**  
  - SwiftUI `struct` 기반 뷰 (예: `StartWalkView`, `HomeView`, `ProfileTabView` 등)  
  - `@StateObject` 또는 `@ObservedObject`로 ViewModel 보유  
- **ViewModel**  
  - `ObservableObject` 채택, `@Published` 프로퍼티로 상태 노출 (`StartWalkViewModel` 등)  
  - 사용자 액션 메서드 (`startWalk()`, `pauseWalk()` 등) 정의  
- **Model**  
  - 순수 데이터 구조체/클래스 (`WalkSession`, `Item`, API 응답 모델 등)  

## 3.3.2 Service 레이어 & DI(의존성 주입)  
- **서비스 객체**  
  - `WalkTrackingService` 클래스: 위치 트래킹, 거리·칼로리·속도 계산 등 로직 집중  
  - `MapService` 계층: `NaverMapView` 래핑  
- **의존성 주입**  
  - ViewModel 초기화 시 기본 파라미터로 서비스 인스턴스 주입  
  - 단위 테스트용 모의 서비스 교체 가능  

## 3.3.3 반응형 패턴 (Combine)  
- 서비스(`WalkTrackingService`)에서 `@Published` 프로퍼티로 위치·통계 데이터 발행  
- ViewModel에서 해당 퍼블리셔 구독(`.sink`) 후 `@Published` 업데이트  
- View는 `@Published` 상태 변경 시 자동 리렌더링

## 3.3.4 기타 디자인 패턴  
- **Singleton**: 전역 단일 인스턴스 패턴 사용 없음 (서비스는 ViewModel 소유)  
- **Coordinator**: 명시적 Coordinator 패턴 미사용  
- **Extensions**: `Color+Hex.swift` 등으로 편의 확장 제공  
- **Asset Catalog**: `Assets.xcassets`로 리소스 구조화  

## 3.3.5 컴포넌트 관계도 예시

```mermaid
graph LR
  View[SwiftUI View]
  VM[ViewModel<br/>(ObservableObject)]
  Service[Service Layer<br/>(WalkTrackingService)]
  Model[Data Model<br/>(WalkSession, Item)]

  View --> VM : 사용자 이벤트 호출
  VM --> Service : 로직 위임(startWalk, pauseWalk 등)
  Service --> VM : Combine 발행(@Published)
  VM --> View : @Published 상태 반영
  VM --> Model : 세션 생성(endWalk 반환)
```

---
위 분석을 바탕으로 주요 패턴 및 컴포넌트 관계를 정리했습니다.

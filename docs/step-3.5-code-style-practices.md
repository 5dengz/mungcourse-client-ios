# 3.5 코드 스타일·베스트 프랙티스 점검

## 3.5.1 네이밍 컨벤션
- **타입명**: `PascalCase` (예: `StartWalkViewModel`, `WalkTrackingService`)
- **변수·메서드**: `camelCase` (예: `startWalk()`, `hasCompletedOnboarding`)
- **상수**: 상수지만 Swift에서는 `camelCase` 유지 (예: `caloriesPerKmMultiplier`)
- **파일명**: 타입명과 일치시키고 확장자는 `.swift` (예: `HomeView.swift`)

## 3.5.2 코드 구조 일관성
- `import` 그룹: 시스템 프레임워크 → 서드파티 SDK → 내부 모듈 순서
- 프로퍼티 및 메서드 구역 구분 (`// MARK:`) 사용
- SwiftLint 같은 툴로 자동 포맷팅 적용 권장

## 3.5.3 옵셔널 처리 및 에러 핸들링
- `guard let` 또는 `if let`으로 옵셔널 안전 해제
- 강제 언래핑(`!`) 최소화; 가능하면 기본값 또는 `fatalError` 대신 사용자 메시지 처리
- `do-catch` 블록으로 오류 처리하거나, `Result` 타입 활용

## 3.5.4 의존성 관리
- 서비스와 뷰모델 생성 시 기본 파라미터 DI 사용 (테스트 교체 용이)
- 싱글톤은 지양하고, 필요한 경우만 `static let shared` 로 제한

## 3.5.5 성능 최적화
- UI 업데이트는 메인 스레드에서만 수행
- Combine 구독은 `receive(on: DispatchQueue.main)` 적용 검토
- `@Published` 빈번 업데이트 시, 최소限 퍼블리셔 필터링(예: `.removeDuplicates()`) 고려

## 3.5.6 메모리 관리
- Combine 구독 시 `weak self` 캡처로 순환 참조 방지
- 타이머나 `CLLocationManager` 사용 후 반드시 해제 또는 `invalidate()`
- SwiftUI 뷰에서 `@StateObject` 사용으로 라이프사이클 보장

---  
위 체크리스트를 통해 코드 일관성, 안전성, 성능, 메모리 관리 관점에서 베스트 프랙티스 준수 여부를 검토했습니다.

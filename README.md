# mungcourse-client-ios

멍코스 iOS 클라이언트 애플리케이션입니다.

## 현재 브랜치

`feature/home-ui-1`

## 기술 스택

*   **UI**: SwiftUI
*   **데이터 관리**: SwiftData (현재 설정만 되어 있으며, UI 연동은 미구현)
*   **언어**: Swift

## 현재 구현된 기능 및 구조

현재 `feature/home-ui-1` 브랜치를 기준으로 다음과 같은 내용이 구현되어 있습니다.

1.  **탭 기반 네비게이션**:
    *   `ContentView.swift` 파일에서 `TabView`를 사용하여 앱의 메인 네비게이션 구조를 구현했습니다.
    *   총 5개의 탭이 존재합니다:
        *   홈 (`HomeView`)
        *   산책 시작 (구현 예정)
        *   루틴 설정 (구현 예정)
        *   산책 기록 (구현 예정)
        *   프로필 (구현 예정)
    *   앱 전체에 일관된 테마 색상 (`#48CF6E`)이 `accentColor`로 적용되었습니다.

2.  **홈 화면 (`HomeView`)**:
    *   `ContentView.swift` 내에 `HomeView` 구조체로 구현되어 있습니다.
    *   `ScrollView`와 `VStack`을 사용하여 홈 화면의 기본적인 레이아웃을 구성했습니다.
    *   다음과 같은 섹션들이 Placeholder 형태로 존재합니다 (실제 기능 미구현):
        *   `ProfileArea`: 사용자 프로필 표시 영역
        *   `ButtonArea`: 주요 액션 버튼 영역 (예: 산책 시작)
        *   `NearbyTrailsArea`: 주변 추천 산책로 표시 영역
        *   `WalkIndexArea`: 날씨 기반 산책 지수 표시 영역
        *   `PastRoutesArea`: 최근 산책 기록 또는 추천 경로 표시 영역

3.  **데이터 모델**:
    *   `Item.swift` 파일에 SwiftData 모델이 정의되어 있습니다. (기본 템플릿 코드일 수 있음)
    *   `mungcourseApp.swift`에서 `ModelContainer`를 설정하여 SwiftData를 사용할 준비는 되어 있으나, 현재 UI와 직접적으로 연동되지는 않았습니다.

4.  **유틸리티**:
    *   `ContentView.swift`에 `Color` 확장이 포함되어 있어 Hex 코드를 사용하여 색상을 쉽게 정의할 수 있습니다.

## 진행 상황 및 다음 단계

*   **진행 상황**: 앱의 기본적인 탭 구조와 홈 화면의 레이아웃 틀이 마련되었습니다. SwiftData 설정이 완료되었습니다.
*   **다음 단계**:
    *   홈 화면(`HomeView`)의 각 Placeholder 섹션에 실제 데이터와 기능을 구현합니다.
    *   SwiftData를 활용하여 필요한 데이터를 저장하고 불러오는 로직을 구현합니다.
    *   '산책 시작', '루틴 설정', '산책 기록', '프로필' 탭 화면을 디자인하고 구현합니다.
    *   API 연동이 필요한 경우, 네트워킹 로직을 추가합니다.

## 코드 구조 요약

*   `mungcourseApp.swift`: 앱 진입점, SwiftData `ModelContainer` 설정
*   `ContentView.swift`: 메인 `TabView` 및 탭 아이템 정의, `HomeView` 및 Placeholder 뷰(`ProfileArea`, `ButtonArea` 등) 정의, Hex Color 확장
*   `Item.swift`: SwiftData 모델 정의 (현재 사용되지 않음)
*   `Assets.xcassets`: 앱 아이콘, AccentColor 등 리소스 관리
*   `Info.plist`: 앱 설정 정보

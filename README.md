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

1.  **탭 기반 네비게이션**: (이전 내용과 동일)
    *   `ContentView.swift` 파일에서 `TabView`를 사용하여 앱의 메인 네비게이션 구조를 구현했습니다.
    *   총 5개의 탭이 존재합니다: 홈 (`HomeView`), 산책 시작, 루틴 설정, 산책 기록, 프로필 (탭 아이콘 에셋 사용).
    *   앱 전체에 일관된 테마 색상 (`#48CF6E`)이 `accentColor`로 적용되었습니다.

2.  **홈 화면 (`HomeView.swift`)**:
    *   `ScrollView`와 `VStack`을 사용하여 홈 화면의 기본적인 레이아웃을 구성했습니다.
    *   **주요 섹션 및 컴포넌트:**
        *   `ProfileArea` (in `HomeView.swift`):
            *   사용자 인사 및 강아지 이름 표시.
            *   강아지 이름을 탭하면 `.confirmationDialog`를 통해 등록된 다른 강아지를 선택할 수 있습니다. (기존 드롭다운 방식 개선)
            *   프로필 이미지 표시 (현재 시스템 아이콘 사용).
            *   내부 `HStack`의 좌우 패딩 제거.
        *   `ButtonArea` (in `HomeView.swift`):
            *   주요 액션 버튼 2개를 가로로 배치 (`HStack` 사용, 간격 9px).
            *   `MainButton` 컴포넌트를 재사용하여 버튼 구현.
                *   "산책 시작" 버튼: `accentColor` 배경, `start_walk` 커스텀 아이콘 사용.
                *   "코스 선택" 버튼: 흰색 배경, `accentColor` 전경색, `select_course` 커스텀 아이콘, `#D9D9D9` 테두리 적용.
        *   `NearbyTrailsArea` (`Components/NearbyTrailsArea.swift`): 주변 추천 산책로 표시 영역 (Placeholder). 컴포넌트로 분리됨.
        *   `WalkIndexArea` (in `HomeView.swift`): 날씨 기반 산책 지수 표시 영역 (Placeholder).
        *   `PastRoutesArea` (`Components/PastRoutesArea.swift`): 최근 산책 기록 또는 추천 경로 표시 영역 (Placeholder). 컴포넌트로 분리됨.
    *   **사용된 주요 문법/기술:** `@State` (강아지 이름, 다이얼로그 표시 상태 관리), `HStack`, `VStack`, `ScrollView`, `Button`, `Image`, `.confirmationDialog`, `.overlay`, `.padding`, `.font`, `.foregroundColor`, `.background`, `.cornerRadius`, `Spacer`.

3.  **공용 컴포넌트 (`mungcourse/Views/Components/`)**:
    *   `MainButton.swift`: 홈 화면의 주요 버튼 스타일을 정의하는 재사용 가능한 컴포넌트.
        *   `title`, `imageName` (에셋 이름), `backgroundColor`, `foregroundColor`, `action`을 파라미터로 받습니다.
        *   `RoundedRectangle` 배경 (cornerRadius: 9).
        *   `ZStack`을 사용하여 좌상단에 텍스트, 우하단에 아이콘 배치.
        *   배경색이 흰색일 경우 `#D9D9D9` 색상의 1px 내부 테두리 자동 적용 (`.stroke` 사용).
    *   `NearbyTrailsArea.swift`: 주변 산책로 섹션 뷰 (Placeholder).
    *   `PastRoutesArea.swift`: 지난 경로 섹션 뷰 (Placeholder).

4.  **데이터 모델**:
    *   `Item.swift` 파일에 SwiftData 모델이 정의되어 있습니다. (현재 UI와 직접 연동되지 않음)
    *   `mungcourseApp.swift`에서 `ModelContainer`를 설정하여 SwiftData를 사용할 준비는 되어 있습니다.

5.  **유틸리티**:
    *   `mungcourse/Extensions/Color+Hex.swift`: Hex 코드를 사용하여 `Color`를 생성하는 확장 기능.

## 진행 상황 및 다음 단계

*   **진행 상황**:
    *   앱의 기본적인 탭 구조 설정 완료.
    *   홈 화면의 기본 레이아웃 및 주요 UI 요소 (프로필 영역, 메인 버튼, 섹션 구분) 구현 완료.
    *   홈 화면 내 재사용 가능한 부분 (주변 산책로, 지난 경로, 메인 버튼)을 별도 컴포넌트로 분리하여 코드 구조 개선.
    *   SwiftData 설정 완료.
*   **다음 단계**:
    *   홈 화면(`HomeView`)의 `WalkIndexArea` 및 분리된 컴포넌트(`NearbyTrailsArea`, `PastRoutesArea`)에 실제 데이터 연동 및 상세 UI 구현.
    *   `ProfileArea`에 실제 강아지 데이터 목록 연동 및 프로필 이미지 기능 구현.
    *   `ButtonArea`의 버튼 액션(네비게이션 등) 구현.
    *   SwiftData를 활용하여 필요한 데이터(강아지 정보, 산책 기록 등) 저장 및 로드 로직 구현.
    *   '산책 시작', '루틴 설정', '산책 기록', '프로필' 탭 화면 디자인 및 구현 시작.
    *   필요시 API 연동을 위한 네트워킹 로직 추가.

## 코드 구조 요약

*   `mungcourseApp.swift`: 앱 진입점, SwiftData `ModelContainer` 설정.
*   `ContentView.swift`: 메인 `TabView` 및 탭 아이템 정의.
*   `Views/`: 화면 단위 뷰 폴더.
    *   `HomeView.swift`: 홈 화면의 전체 구조 및 `ProfileArea`, `ButtonArea`, `WalkIndexArea` 정의.
    *   `Components/`: 재사용 가능한 UI 컴포넌트 폴더.
        *   `MainButton.swift`: 홈 화면 메인 버튼 컴포넌트.
        *   `NearbyTrailsArea.swift`: 주변 산책로 섹션 컴포넌트.
        *   `PastRoutesArea.swift`: 지난 경로 섹션 컴포넌트.
    *   (기타 탭 뷰 파일들...)
*   `Models/`: 데이터 모델 폴더.
    *   `Item.swift`: SwiftData 모델 정의 (현재 구체적인 사용 없음).
*   `Extensions/`: Swift 확장 기능 폴더.
    *   `Color+Hex.swift`: Hex 색상 코드 변환 확장.
*   `Assets.xcassets`: 앱 아이콘, AccentColor, 커스텀 이미지 에셋 (`start_walk`, `select_course` 등) 관리.
*   `Info.plist`: 앱 설정 정보.

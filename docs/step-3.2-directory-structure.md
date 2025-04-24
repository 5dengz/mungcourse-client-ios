# 3.2 디렉터리 구조 및 파일 목록 정리

## 최상위 구조
- .gitignore: Git 추적 제외 파일 목록  
- git-rules.md: Git 커밋·브랜치 규칙  
- README.md: 프로젝트 개요 및 실행 방법  
- docs/: 문서 디렉터리 (분석 계획, 아키텍처 문서 등)  
- mungcourse/: 소스 코드 루트 디렉터리  
- mungcourse.xcodeproj: Xcode 프로젝트 파일  
- mungcourseTests/: 유닛 테스트 코드  
- mungcourseUITests/: UI 테스트 코드  

## mungcourse/ 하위 구조
- Info.plist: 앱 설정  
- mungcourse.entitlements: 권한 설정  
- mungcourseApp.swift: 앱 진입점 (SwiftUI App)  
- Assets.xcassets/: 이미지 및 컬러 자원  
  - AccentColor.colorset  
  - AppIcon.appiconset  
  - home.imageset, map.imageset 등

### Config
- APIKeys.swift: API 키 관리 및 환경 변수

### Extensions
- Color+Hex.swift: Hex 코드로 UIColor/Color 생성 확장

### Models
- Item.swift: 주요 데이터 모델 정의

### Modules
- Common  
  - Components: MainButton.swift, RoundTripTimeView.swift  
  - Views: LoadingView.swift  

- Onboarding  
  - Components: OnboardingPageView.swift  
  - Views: OnboardingView.swift  

- Home  
  - Components: TrailItemView.swift  
  - Views: HomeView.swift, NearbyTrailsView.swift, PastRoutesView.swift, WalkIndexView.swift  

- Walk  
  - Components: WalkControlButton.swift, WalkStatsBar.swift  
  - Models: WalkSession.swift  
  - ViewModels: StartWalkViewModel.swift  
  - Views: StartWalkView.swift  

- History  
  - Views: WalkHistoryView.swift  

- Profile  
  - Views: ProfileTabView.swift, RoutineSettingsView.swift  

- Main  
  - Views: ContentView.swift

### Services
- MapService  
  - NaverMapView.swift: 지도 렌더링  
  - WalkTrackingService.swift: 위치 추적 로직

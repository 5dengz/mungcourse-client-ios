# mungcourse-client-ios 코드 분석 계획

## 1. 목표  
- 전체 코드 구조 파악  
- 주요 모듈·컴포넌트별 역할 및 책임 분석  
- 사용된 디자인 패턴 식별  
- 로직 흐름(데이터 흐름, 의존성) 분석  
- 개선 가능 지점 및 리팩토링 포인트 도출

## 2. 분석 대상  
- 앱 진입점 (mungcourseApp.swift, ContentView)  
- 모듈별 디렉토리 (Onboarding, Home, Walk, History, Profile 등)  
- 공통 유틸·서비스 (Config/APIKeys.swift, Extensions, Services)  
- 모델·데이터 레이어 (Models, ViewModels)  
- 리소스 및 에셋 구성 (Assets.xcassets)  
- 테스트 코드 (mungcourseTests, mungcourseUITests)

## 3. 단계별 계획  

### 3.1 환경 설정 및 빌드 확인  
- Xcode 프로젝트 열어 시뮬레이터 빌드 및 실행  
- 의존성(CocoaPods/Swift Package 등) 설치 여부 점검  

### 3.2 디렉터리 구조 및 파일 목록 정리  
- 주요 폴더(Modules, Services, Models 등) 구조도 작성  
- 각 디렉터리별 책임 정리  

### 3.3 아키텍처·디자인 패턴 식별  
- MVVM, Coordinator, Singleton, Dependency Injection 등 사용 여부 확인  
- View, ViewModel, Service, Model 간 관계도 작성  

### 3.4 로직·데이터 흐름 분석  
- 화면 간 네비게이션 흐름  
- API 호출 및 데이터 파싱 흐름  
- 상태 관리 방식(State, Binding 등) 분석  

### 3.5 코드 스타일·베스트 프랙티스 점검  
- 네이밍 컨벤션, 코드 구조 일관성  
- 에러 처리, 옵셔널 핸들링  
- 성능 및 메모리 관리 패턴  



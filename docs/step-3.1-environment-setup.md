# 3.1 환경 설정 및 빌드 확인

## 3.1.1 의존성 점검
- CocoaPods: Podfile 없음  
- Swift Package Manager: Package.swift 없음  
- 외부 라이브러리(써드파티) 미사용

## 3.1.2 빌드 방법
Xcode 프로젝트 파일(`mungcourse.xcodeproj`)을 이용해 커맨드라인에서 빌드할 수 있습니다:
```bash
cd mungcourse
xcodebuild \
  -project mungcourse.xcodeproj \
  -scheme mungcourse \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 14' \
  build
```
- 위 명령으로 시뮬레이터(iPhone 14) 대응 빌드가 성공해야 합니다.

## 3.1.3 실행 확인
- Xcode에서 `mungcourseApp.swift`을 진입점으로 실행  
- 시뮬레이터(예: iPhone 14)에서 Onboarding 화면이 정상적으로 표시됨

---
위 내용을 바탕으로 빌드 환경과 실행이 정상임을 확인했습니다.

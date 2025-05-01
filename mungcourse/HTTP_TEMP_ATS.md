# HTTP 임시 허용 (ATS 예외) 가이드

## 1. 목적
- 개발 및 테스트 환경에서 HTTPS 미지원 서버(http://)를 임시로 허용하기 위해 사용합니다.
- 운영 환경으로 전환 시, 반드시 이 설정을 제거해야 합니다.

## 2. Info.plist 설정
```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```
- 위 설정을 추가하면 앱 전체에 대해 HTTP 요청이 허용됩니다.
- 나중에 HTTPS로 이관할 때, `<key>NSAppTransportSecurity</key>` 블록을 모두 삭제하세요.

## 3. 주의사항
- **운영 환경에서는 HTTPS만 사용**해야 합니다.
- ATS 예외 설정(`NSAllowsArbitraryLoads`)이 남아 있으면 보안 취약점이 발생할 수 있습니다. 
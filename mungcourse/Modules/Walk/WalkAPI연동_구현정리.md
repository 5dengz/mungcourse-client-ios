# Walk API 연동 및 구현 현황 (2025-04-28)

## 1. 구현된 부분

- 산책 종료 시 WalkSession 데이터를 서버로 업로드하는 기능 구현
    - WalkSession 모델에 서버 업로드용 변환 메서드(`toAPIDictionary`) 추가
    - StartWalkViewModel에 업로드 함수(`uploadWalkSession`) 구현
    - StartWalkView에서 산책 종료 시 업로드 함수 호출
    - 업로드 시 임시로 dogIds는 `[1]`로 지정
    - 업로드 시 인증 토큰 등은 아직 미연동

## 2. 구현 방법 요약

1. 산책 중 경로, 거리, 시간 등 정보를 ViewModel에서 누적 관리
2. 산책 종료 시 WalkSession 인스턴스 생성
3. WalkSession을 서버 DTO로 변환하여 `/v1/walks` 엔드포인트로 POST 요청
4. 업로드 성공/실패에 따라 후처리 가능

## 3. 추후 구현해야 할 것

- 실제 dogIds(사용자가 선택한 강아지 id 배열) 연동
- 서버 요청 시 access token(인증 헤더) 추가
    - 토큰 만료 시 /auth/refresh로 재발급 처리 필요
    - 위조/만료 시 로그아웃 처리
- 업로드 성공/실패에 따른 UI 알림 및 예외 처리 강화
- 서버 응답값 활용(예: 산책 id, 서버 저장 결과 등)
- 네트워크 에러, 서버 에러 등 상세 처리

---

> 이 문서는 Walk API 연동 현황 및 추후 구현 계획을 정리한 문서입니다. 실제 구현 코드와 연동되는 부분은 계속 업데이트 필요.

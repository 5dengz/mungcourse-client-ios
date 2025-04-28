## 목적

- 프론트 엔드와 백엔드 간의 통신에 이용되는 URI 명세
- 백엔드 기준으로 작성하였으며 자세한 내용은 기능정의서 참조
- REST API 설계 지향
    - ex) GET, POST, PATCH, DELETE /v1/members

---

## API

- Swagger로 작성 예정
- 요청 HTTP의 body에 값이 필요 없는 케이스는 비워 둠
- /login, /refresh, /logout을 제외한 모든 페이지에서 헤더에 access token 필요
    - 토큰이 없으면 로그인 화면으로 이동 (화면 이동은 프론트에서 처리)
    - 토큰이 만료된거면 /auth/refresh로 access 토큰 재발급 요청
    - 토큰이 위조된거면 /auth/logout로 강제 로그아웃 후 로그인 화면으로 이동

---

# Auth

## `auth/{provider}/login`

- `POST` OAuth 로그인 및 회원가입
    - URI : v1/auth/google/login
    
    - 요청
        
        ```jsx
        POST /v1/auth/google/login
        Content-Type: application/json
        
        {
          "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6..."
        }
        
        ```
        
    
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
              "timestamp": "2025-04-09T14:32:00Z",
              "statusCode": 200,
              "success": true,
              "data": {
                "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "user": {
                  "id": 1,
                  "sub": "1039283948029109238492",
                  "email": "user@gmail.com",
                  "name": "홍길동",
                  "provider": "google"
                },
                "is_new_user": true
              }
            }
            ```
            
        - 실패
            - 유효하지 않은 토큰값(401)
                
                ```jsx
                HTTP/1.1 401 Unauthorized
                Content-Type: application/json
                
                {
                  "timestamp": "2025-04-09T14:40:00Z",
                  "statusCode": 401,
                  "success": false,
                  "error": "INVALID_GOOGLE_ID_TOKEN",
                  "message": "유효하지 않은 구글 토큰입니다.",
                  "data": null
                }
                ```
                
            - 서버 문제(502)
                
                ```jsx
                HTTP/1.1 502 Bad Gateway
                Content-Type: application/json
                
                {
                  "timestamp": "2025-04-09T14:40:00Z",
                  "statusCode": 502,
                  "success": false,
                  "error": "GOOGLE_AUTH_SERVER_ERROR",
                  "message": "구글 인증 서버와의 통신에 실패했습니다. 잠시 후 다시 시도해주세요.",
                  "data": null
                }
                ```
                
    

## `auth/refresh`

- `POST` 토큰 재발급
    - URI : v1/auth/refresh
    - 서버에서 **ACCESS_TOKEN_EXPIRED** 에러 코드를 전송할 때 클라이언트에서 요청
    
    - 요청
        
        ```jsx
        POST /v1/auth/refresh
        Authorization-Refresh : Bearer {리프레시 토큰값}
        
        ```
        
    
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
              "timestamp": "2025-04-09T14:32:00Z",
              "statusCode": 200,
              "success": true,
              "data": {
                "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                },
            }
                
            ```
            
        - 실패
            - 유효하지 않은 리프레시 토큰값(401)
                
                ```jsx
                HTTP/1.1 401 Unauthorized
                Content-Type: application/json
                
                {
                  "timestamp": "2025-04-09T14:40:00Z",
                  "statusCode": 401,
                  "success": false,
                  "error": "INVALID_REFRESH_TOKEN",
                  "message": "유효하지 않은 리프레시 토큰입니다.",
                  "data": null
                }
                ```
                
            - 리프레시 토큰 값이 존재하지 않음(401)
            - 리프레시 토큰 값이 만료됨(401)
            - 기타(500)
                
                ```jsx
                HTTP/1.1 500 Internal Server Error
                Content-Type: application/json
                
                {
                  "timestamp": "2025-04-09T18:00:00Z",
                  "statusCode": 500,
                  "success": false,
                  "error": "INTERNAL_SERVER_ERROR",
                  "message": "서버에 오류가 발생했습니다. 잠시 후 다시 시도해주세요.",
                  "data": null
                }
                ```
                
        

## `auth/logout`

- `POST` 로그아웃
    - URI : v1/auth/logout
    - 클라이언트는 서버에서 로그아웃 확인 후 메모리의 ACCESS, REFRESH 토큰 제거
    
    - 요청 (클라이언트 요청 헤더에 Refresh Token이 있으면 제거 후 로그아웃, 없으면 그대로 로그아웃)
        
        ```jsx
        POST /v1/auth/logout
        Authorization-Refresh : Bearer {리프레시 토큰값}
        
        ```
        
    
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
              "timestamp": "2025-04-09T15:00:00Z",
              "statusCode": 200,
              "success": true,
              "message": "로그아웃 되었습니다.",
              "data": null
            }
                
            ```
            
        - 실패
            - 유효하지 않은 리프레시 토큰값(401)
                
                ```jsx
                HTTP/1.1 401 Unauthorized
                Content-Type: application/json
                
                {
                  "timestamp": "2025-04-09T14:40:00Z",
                  "statusCode": 401,
                  "success": false,
                  "error": "INVALID_REFRESH_TOKEN",
                  "message": "유효하지 않은 리프레시 토큰입니다.",
                  "data": null
                }
                ```
                
            - 기타(500)
        

## `auth/me`

- `GET` 로그인 된 유저 정보 가져오기
    - URI : v1/auth/me
    - 보안상 문제로 user 테이블 관련 엔드포인트로 직접 가져오지 않고 auth/me로 정보 가져옴
    
    - 요청
    
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
              "timestamp": "2025-04-09T15:50:00Z",
              "statusCode": 200,
              "success": true,
              "data": {
                "id": 1,
                "sub": "1039283948029109238492",
                "email": "user@gmail.com",
                "name": "홍길동",
                "provider": "google"
              }
            }
            
                
            ```
            
        - 실패
            - 유효하지 않은 access 토큰값(401)
                
                ```jsx
                HTTP/1.1 401 Unauthorized
                Content-Type: application/json
                
                {
                  "timestamp": "2025-04-09T14:40:00Z",
                  "statusCode": 401,
                  "success": false,
                  "error": "INVALID_ACCESS_TOKEN",
                  "message": "유효하지 않은 엑세스 토큰입니다.",
                  "data": null
                }
                ```
                
            - 기타(500)
        
- `PATCH` 기본 값에서 유저 정보 수정하기
    - URI : v1/auth/me
    
    - 요청
        
        ```jsx
        PATCH /v1/auth/me
        Content-Type: application/json
        
        {
          "name": "젤리 보호자",
        }
            
        ```
        
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
              "timestamp": "2025-04-09T16:20:00Z",
              "statusCode": 200,
              "success": true,
              "data": {
                "id": 1,
                "name": "젤리 보호자"
              }
            }
            
                
            ```
            
        - 실패
            - 유효하지 않은 access 토큰값(401)
            - 기타(500)

- `DELETE` 회원 탈퇴하기
    - URI : v1/auth/me
    
    - 요청
        
        ```jsx
        DELETE /v1/auth/me
        Content-Type: application/json
        
        {
          "reasons": [
            "앱이 저와 맞지 않아요",
            "기능이 부족해요",
            "다른 서비스를 이용하고 싶어요"
          ],
          "additional_reason": "UI가 불편했어요"
        }
        ```
        
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
              "timestamp": "2025-04-09T16:35:00Z",
              "statusCode": 200,
              "success": true,
              "message": "회원탈퇴가 완료되었습니다.",
              "data": null
            }
                
            ```
            
        - 실패
            - 유효하지 않은 access 토큰값(401)
            - 기타(500)

# Dog

## `dogs`

- `GET` 등록한 강아지들 정보 가져오기
    - URI : v1/dogs
        
        ![image.png](attachment:04d8acf4-7865-404c-8be3-b563cef72c69:image.png)
        
    
    - 요청
    
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
              "timestamp": "2025-04-09T16:35:00Z",
              "statusCode": 200,
              "success": true,
              "data": [
                {
                  "id": 1,
                  "name": "망고",
                  "dog_img_url": "https://example.com/mango.jpg",
                  "is_main": true,
                },
                {
                  "id": 2,
                  "name": "크림이",
                  "dog_img_url": "https://example.com/cream.jpg",
                  "is_main": false,
                }
              ]
            }
            ```
            
        - 실패
            - 유효하지 않은 access 토큰값(401)
            - 기타(500)
    
- `POST` 강아지 정보 등록하기
    - URI : v1/dogs
        
        ![image.png](attachment:dc86c7e9-4155-4296-9d7a-8fd3c4b89a3a:image.png)
        
    - 요청
        
        ```jsx
        POST /v1/dogs
        Content-Type: application/json
        
        {
            "name": "흰둥이",
            "gender": "여아",
            "breed": "말티즈",
            "birth_date": "2002-04-08",
            "weight": 4.4,
            "has_arthritis" : true,
            "neutered": true,
            "dog_img_url": "https://example.com/mango.jpg",
            // is_main 여부는 최초 등록 강아지만 true, 나머지는 default가 false
         }
        ```
        
    
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
              "timestamp": "2025-04-09T17:00:00Z",
              "statusCode": 200,
              "success": true,
              "data": {
                "name": "흰둥이",
                "gender": "여아",
                "breed": "말티즈",
                "birth_date": "2002-04-08",
                "weight": 4.4,
                "has_arthritis" : true,
                "neutered": true,
                "dog_img_url": "https://example.com/mango.jpg",
                "is_main": true
              }
            }
            ```
            
        - 실패
            - 유효하지 않은 access 토큰값(401)
            - 기타(500)
    

## `dogs/main`

- `GET` 대표로 설정해놓은 강아지 가져오기
    - URI : v1/dogs/main
        
        ![image.png](attachment:0306eccf-369a-475c-b52a-0ed09eb56b04:image.png)
        
    
    - 요청
    
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
              "timestamp": "2025-04-09T17:00:00Z",
              "statusCode": 200,
              "success": true,
              "data": {
                "name": "흰둥이",
                "dog_img_url": "https://example.com/mango.jpg",
                "is_main": true
              }
            }
            ```
            
        - 실패
            - 유효하지 않은 access 토큰값(401)
            - 기타(500)

## `dogs/{dog_id}`

- `GET` 등록한 강아지 세부 정보 가져오기
    - URI : v1/dogs/{dog_id}
        
        ![image.png](attachment:dbd06e37-6d4f-4d49-9d26-9d4df1d38249:image.png)
        
    
    - 요청
    
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
              "timestamp": "2025-04-09T17:00:00Z",
              "statusCode": 200,
              "success": true,
              "data": {
                "id": 2,
                "name": "망고",
                "gender": "여아",
                "breed": "푸들",
                "birth_date": "2022-04-01",
                "weight": 3.2,
                "has_arthritis" : true,
                "neutered": true,
                "dog_img_url": "https://example.com/mango.jpg",
                "is_main": false
              }
            }
            ```
            
        - 실패
            - 유효하지 않은 access 토큰값(401)
            - 자신의 강아지가 아닌 경우 (403)
                
                ```jsx
                HTTP/1.1 403 Forbidden
                Content-Type: application/json
                
                {
                  "timestamp": "2025-04-09T17:00:00Z",
                  "statusCode": 403,
                  "success": false,
                  "error": "FORBIDDEN_DOG_ACCESS",
                  "message": "해당 강아지에 접근할 권한이 없습니다.",
                  "data": null
                }
                ```
                
            - 존재하지 않는 강아지 id (404)
                
                ```jsx
                HTTP/1.1 404 Not Found
                Content-Type: application/json
                
                {
                  "timestamp": "2025-04-09T17:00:00Z",
                  "statusCode": 404,
                  "success": false,
                  "error": "DOG_NOT_FOUND",
                  "message": "해당 강아지를 찾을 수 없습니다.",
                  "data": null
                }
                ```
                
            - 기타(500)

- `PATCH` 강아지 세부 정보 수정하기
    - URI : v1/dogs/{dog_id}
    
    - 요청
        
        ```jsx
        PATCH /v1/dogs/2
        Content-Type: application/json
        
        {
          "name": "젤리",
          "weight": 3.8
        }
        
        ```
        
    
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
              "timestamp": "2025-04-09T17:00:00Z",
              "statusCode": 200,
              "success": true,
              "data": {
                "id": 2,
                "name": "젤리",
                "weight": 3.8,
              }
            }
            ```
            
        - 실패
            - 유효하지 않은 access 토큰값(401)
            - 자신의 강아지가 아닌 경우 (403)
            - 존재하지 않는 강아지 id (404)
            - 기타(500)

- `DELETE` 강아지 정보 삭제하기
    - URI : v1/dogs/{dog_id}
    - 만약 메인 강아지를 삭제했다면, 등록된지 가장 오래된 강아지를 메인 강아지로 설정
    
    - 요청
        
        ```jsx
        DELETE /v1/dogs/2
        Content-Type: application/json
        
        ```
        
    
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
              "timestamp": "2025-04-09T17:00:00Z",
              "statusCode": 200,
              "success": true,
              "data": {
                "id": 2,
                "name": "망고",
                "gender": "여아",
                "breed": "푸들",
                "birth_date": "2022-04-01",
                "weight": 3.2,
                "has_arthritis" : true,
                "neutered": true,
                "dog_img_url": "https://example.com/mango.jpg",
                "is_main": false
              }
            }
            ```
            
        - 실패
            - 유효하지 않은 access 토큰값(401)
            - 자신의 강아지가 아닌 경우 (403)
            - 존재하지 않는 강아지 id (404)
            - 기타(500)

## `dogs/{dog_id}/walks`

- `GET` 특정 강아지의 산책 기록 가져오기
    - URI : v1/dogs/{dog_id}/walks
        
        ![image.png](attachment:dbd06e37-6d4f-4d49-9d26-9d4df1d38249:image.png)
        
    
    (여기서 산책 기록 눌렀을 때 화면)
    
    - 요청
    
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
              "timestamp": "2025-04-09T17:00:00Z",
              "statusCode": 200,
              "success": true,
              "data": [
               {
                  "id": 101,
                  "distance_km": 2.1,
                  "duration_sec": 1800,
                  "calories": 123,
            		  "started_at": "2025-04-09T07:31:00Z",
            		  "ended_at": "2025-04-09T08:00:00Z",
                },
                {
                  "id": 108,
                  "distance_km": 1.4,
                  "duration_sec": 1400,
                  "calories": 90,
            		  "started_at": "2025-04-09T07:31:00Z",
            		  "ended_at": "2025-04-09T08:00:00Z",
                },
                .
                .
                .
                .
              ]
             
            }
            ```
            
        - 실패
            - 유효하지 않은 access 토큰값(401)
            - 자신의 강아지가 아닌 경우 (403)
            - 존재하지 않는 강아지 id (404)
            - 기타(500)

## `dogs/{dog_id}/main`

- `PATCH` dog_id의 강아지로 대표 강아지 변경
    - URI : v1/dogs/{dog_id}/main
        
        ![KakaoTalk_20250410_114930379.jpg](attachment:8892fe56-c0a6-4d32-90dc-f8932fba3893:KakaoTalk_20250410_114930379.jpg)
        
    - 요청
        
        ```jsx
        PATCH /v1/dogs/2/main
        Content-Type: application/json
        
        {
          "isMain": true,
        }
        
        ```
        
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
              "timestamp": "2025-04-10T06:20:00Z",
              "statusCode": 200,
              "success": true,
              "data": {
                "id": 2,
                "name": "초코",
                "is_main": true
              }
            }
            ```
            
        - 실패
            - 유효하지 않은 access 토큰값(401)
            - 기타(500)

# Walk

## `walks`

- `GET` 산책 기록 리스트로 조회하는데 파라미터로 날짜 받아서 해당 날짜 산책만 조회
    - URI : v1/walks
        - `v1/walks?date=2025-04-06` (started_at 날짜 기준)
            
            ![image.png](attachment:421c0a6e-9279-4091-a7bf-cf5d034380a4:image.png)
            
    
    - 요청
    
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
              "timestamp": "2025-04-06T23:59:59Z",
              "statusCode": 200,
              "success": true,
              "data": [
                {
                  "id": 101,
                  "started_at": "2025-04-06T07:12:00Z",
                  "ended_at": "2025-04-06T07:42:00Z",
                  "distance_km": 1.07,
                  "duration_sec": 1800,
                  "calories": 128,
                  "dog_ids": [1, 2], // 선택한 강아지들을 배열로 묶음
                  "gps_data": [
                    { "lat": 37.1234, "lng": 127.1234 },
                    { "lat": 37.1235, "lng": 127.1235 },
                    .
                    .
                  ]
                },
                {
                  "id": 102,
                  "started_at": "2025-04-06T18:05:00Z",
                  "ended_at": "2025-04-06T18:35:00Z",
                  "distance_km": 3.86,
                  "duration_sec": 3600,
                  "calories": 256,
                  "dog_ids": [1],
                  "gps_data": [
                    { "lat": 37.1240, "lng": 127.1240 },
                    { "lat": 37.1245, "lng": 127.1245 },
                    .
                    .
                  ]
                }
              ]
            }
            
            ```
            
        - 실패
            - 날짜 포맷이 잘못됨(400)
                
                ```jsx
                {
                  "timestamp": "2025-04-06T18:00:00Z",
                  "statusCode": 400,
                  "success": false,
                  "error": "INVALID_DATE_FORMAT",
                  "message": "날짜 형식은 YYYY-MM-DD 형식이어야 합니다.",
                  "data": null
                }
                
                ```
                
            - 유효하지 않은 access 토큰값(401)
            - 기타(500)
    

- `POST` 산책 기록 저장하기
    - URI : v1/walks
        
        ![image.png](attachment:c665bc17-27cd-4de2-92c2-1d20ef22ea10:image.png)
        
        해당 사진에서 우측의 중단 눌렀을 때 서버에 기록
        
    
    - 요청
        
        ```jsx
        POST /v1/walks
        Content-Type: application/json
        
        {
          "distance_km": 1.07,
          "duration_sec": 1226,
          "calories": 128,
          "started_at": "2025-04-09T07:00:00Z",
          "ended_at": "2025-04-09T07:30:00Z",
          "dog_ids": [1, 2], // 선택한 강아지들을 배열로 묶음
          "gps_data": [
            { "lat": 37.1234, "lng": 127.1234 },
            { "lat": 37.1235, "lng": 127.1235 },
            .
            .
            .
          ]
        }
        ```
        
    
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
              "timestamp": "2025-04-09T16:35:00Z",
              "statusCode": 200,
              "success": true,
              "data":
                {
                  "id": 1,
                  "distance_km": 1.07,
                  "duration_sec": 1226,
                  "calories": 128,
                  "started_at": "2025-04-06T20:00:00Z",
            		  "ended_at": "2025-04-06T20:20:00Z",
            		  "dog_ids": [1, 2],
            		  "gps_data": [
            		    { "lat": 37.123456, "lng": 127.123456 },
            		    { "lat": 37.123460, "lng": 127.123460 },
            		    .
            		    .
            		    . 
            			] // 혹은 s3 url 링크   
            	}
            }
            ```
            
        - 실패
            - 유효하지 않은 access 토큰값(401)
            - 기타(500)
    

## `walks/{walk_id}`

- `GET` 개별 산책 정보 가져오기
    - URI : v1/walks/{walk_id}
        
        ![image.png](attachment:e9a56801-6f15-43d5-9ace-4f5e7f07a3bc:image.png)
        
    - 요청
    
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
              "timestamp": "2025-04-09T16:35:00Z",
              "statusCode": 200,
              "success": true,
              "data":
                {
                  "id": 1,
                  "distance_km": 1.07,
                  "duration_sec": 1226,
                  "calories": 128,
                  "started_at": "2025-04-06T20:00:00Z",
            		  "ended_at": "2025-04-06T20:20:00Z",
            		  "dog_ids": [1, 2],
            		  "gps_data": [
            		    { "lat": 37.123456, "lng": 127.123456 },
            		    { "lat": 37.123460, "lng": 127.123460 },
            		    .
            		    .
            		    . 
            			] // 혹은 s3 url 링크   
            	}
            }
            ```
            
        - 실패
            - 유효하지 않은 access 토큰값(401)
            - 자신의 산책 기록이 아닌 경우 (403)
                
                ```jsx
                HTTP/1.1 403 Forbidden
                Content-Type: application/json
                
                {
                  "timestamp": "2025-04-09T17:00:00Z",
                  "statusCode": 403,
                  "success": false,
                  "error": "FORBIDDEN_WALK_ACCESS",
                  "message": "해당 산책 기록에 접근할 권한이 없습니다.",
                  "data": null
                }
                ```
                
            - 존재하지 않는 산책 id (404)
                
                ```jsx
                HTTP/1.1 404 Not Found
                Content-Type: application/json
                
                {
                  "timestamp": "2025-04-09T17:00:00Z",
                  "statusCode": 404,
                  "success": false,
                  "error": "DOG_NOT_FOUND",
                  "message": "해당 산책 기록을 찾을 수 없습니다.",
                  "data": null
                }
                ```
                
            - 기타(500)

- `DELETE` 개별 산책 정보 지우기
    - URI : v1/walks/{walk_id}
        
        
    - 요청
    
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
              "timestamp": "2025-04-09T16:35:00Z",
              "statusCode": 200,
              "success": true,
              "data":
                {
                  "id": 1,
                  "distance_km": 1.07,
                  "duration_sec": 1226,
                  "calories": 128,
                  "started_at": "2025-04-06T20:00:00Z",
            		  "ended_at": "2025-04-06T20:20:00Z",
            		  "dog_ids": [1, 2],
            		  "gps_data": [
            		    { "lat": 37.123456, "lng": 127.123456 },
            		    { "lat": 37.123460, "lng": 127.123460 },
            		    .
            		    .
            		    . 
            			] // 혹은 s3 url 링크   
            	}
            }
            ```
            
        - 실패
            - 유효하지 않은 access 토큰값(401)
            - 자신의 산책 기록이 아닌 경우 (403)
                
                ```jsx
                HTTP/1.1 403 Forbidden
                Content-Type: application/json
                
                {
                  "timestamp": "2025-04-09T17:00:00Z",
                  "statusCode": 403,
                  "success": false,
                  "error": "FORBIDDEN_WALK_ACCESS",
                  "message": "해당 산책 기록에 접근할 권한이 없습니다.",
                  "data": null
                }
                ```
                
            - 존재하지 않는 산책 id (404)
                
                ```jsx
                HTTP/1.1 404 Not Found
                Content-Type: application/json
                
                {
                  "timestamp": "2025-04-09T17:00:00Z",
                  "statusCode": 404,
                  "success": false,
                  "error": "DOG_NOT_FOUND",
                  "message": "해당 산책 기록을 찾을 수 없습니다.",
                  "data": null
                }
                ```
                
            - 기타(500)

# Routine

## `routines`

- `GET` 루틴을 리스트로 조회
    - URI : v1/routines
        - `v1/routines?date=2025-04-08`
            
            ![image.png](attachment:87fde245-9210-427c-9b67-3f4dc7a38550:image.png)
            
            (밥 먹기 같은 단일 체크 경우만 보면 될 듯)
            
    - 요청
    
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
              "timestamp": "2025-04-12T09:00:00Z",
              "statusCode": 200,
              "success": true,
              "data": [
                {
                  "routine_check_id": 100,
                  "routine_id": 1,
            		  "routine_schedule_id": 13,
                  "name": "아침 산책",
                  "alarm_time": "09:00",
                  "date": "2025-04-08",
                  "is_completed": true
                },
                {
                  "routine_check_id": 101,
                  "routine_id": 2,
            		  "routine_schedule_id": 17,
                  "name": "저녁 간식",
                  "alarm_time": "20:00",
                  "date": "2025-04-08",
                  "is_completed": false
                }
              ]
            }
            ```
            
        - 실패
            - 날짜 포맷이 잘못됨(400)
                
                ```jsx
                {
                  "timestamp": "2025-04-06T18:00:00Z",
                  "statusCode": 400,
                  "success": false,
                  "error": "INVALID_DATE_FORMAT",
                  "message": "날짜 형식은 YYYY-MM-DD 형식이어야 합니다.",
                  "data": null
                }
                
                ```
                
            - 유효하지 않은 access 토큰값(401)
            - 기타(500)
    
- `POST` 루틴을 등록
    - URI : v1/routines
        
        ![image.png](attachment:01230f57-6751-404d-b87c-b23c2180b34c:image.png)
        
    
    - 요청
        
        ```jsx
        POST /v1/routines
        Content-Type: application/json
        
        {
          "name": "아침 산책",
          "alarm_time": "09:00",
          "repeat_days": ["MON", "TUE", "FRI"] // 요일 enum 값들 (월~일)
        }
        ```
        
    - 응답
        - 성공(200)
            
            ```jsx
            {
              "timestamp": "2025-04-12T12:00:00Z",
              "statusCode": 200,
              "success": true,
              "data": {
                "routine_id": 42,
                "name": "아침 산책",
                "alarm_time": "09:00",
                "repeat_days": ["MON", "TUE", "FRI"]
              }
            }
            
            ```
            
        - 실패
            - 유효하지 않은 access 토큰값(401)
            - 기타(500)

## `routines/{routine_id}`

- `PATCH` 루틴의 정보를 변경 (편집하기 누르는 날짜 기준으로 해당 날짜 + 이후만 변경됨)
    - URI : v1/routines/{routine_id}
    
    - 요청
        
        ```jsx
        PATCH /v1/routines/1
        Content-Type: application/json
        
        {
          "name": "산책",
          "alarm_time": "08:00",
          "repeat_days": ["TUE", "THU"],
          "apply_from_date": "2025-04-08" // 해당 날짜 이후의 routine_check만 변경됨
        }
        ```
        
    
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
            	"timestamp": "2025-04-06T18:00:00Z",
              "statusCode": 200,
              "success": true,
              "data": {
                "routine_id": 1,
                "name": "산책",
                "alarm_time": "08:00",
                "repeat_days": ["TUE", "THU"]
              }
            }
            
            ```
            
        - 실패
            - 날짜 포맷이 잘못됨(400)
            - 유효하지 않은 access 토큰값(401)
            - 본인 루틴이 아니라 권한 없음(403)
                
                ```jsx
                HTTP/1.1 403 Forbidden
                
                {
                  "timestamp": "2025-04-06T18:00:00Z",
                  "statusCode": 403,
                  "success": false,
                  "error": "FORBIDDEN_ROUTINE_ACCESS",
                  "message": "이 루틴에 접근할 권한이 없습니다.",
                  "data": null
                }
                
                ```
                
            - 존재하지 않는 루틴 ID(404)
                
                ```jsx
                HTTP/1.1 404 Not Found
                
                {
                  "timestamp": "2025-04-06T18:00:00Z",
                  "statusCode": 404,
                  "success": false,
                  "error": "ROUTINE_NOT_FOUND",
                  "message": "해당 루틴이 존재하지 않습니다.",
                  "data": null
                }
                
                ```
                
            - 기타(500)

- `DELETE` 특정 루틴들을 전부 삭제 (과거 기록도 삭제됨)
    - URI : v1/routines/{routine_id}
    
    - 요청
    
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
              "timestamp": "2025-04-06T18:00:00Z",
              "statusCode": 200,
              "success": true,
              "message": "루틴이 성공적으로 삭제되었습니다.",
              "data": null
            }
            
            ```
            
        - 실패
            - 유효하지 않은 access 토큰값(401)
            - 본인 루틴이 아니라 권한 없음(403)
            - 존재하지 않는 루틴 ID(404)
            - 기타(500)

## `routines/{routine_check_id}`

- `PATCH` 완료한 루틴을 체크 OR 체크 해제
    - URI : v1/routines/{routine_check_id}
    
    - 요청
        
        ```jsx
        PATCH /v1/routines/101
        Content-Type: application/json
        
        {
          "is_completed": true // 완료한 루틴 체크의 경우
        }
        ```
        
    - 응답
        - 성공(200)
            
            ```jsx
            HTTP/1.1 200 OK
            Content-Type: application/json
            
            {
              "timestamp": "2025-04-12T09:15:00Z",
              "statusCode": 200,
              "success": true,
              "data": {
                "routine_check_id": 101,
                "is_completed": true
              }
            }
            
            ```
            
        - 실패
            - 유효하지 않은 access 토큰값(401)
            - 본인 소유가 아닌 루틴 체크 시도(403)
                
                ```jsx
                HTTP/1.1 403 Forbidden
                
                {
                  "timestamp": "2025-04-12T09:15:00Z",
                  "statusCode": 403,
                  "success": false,
                  "error": "FORBIDDEN_ROUTINE_CHECK",
                  "message": "이 루틴은 현재 사용자에게 속하지 않습니다.",
                  "data": null
                }
                
                ```
                
            - 존재하지 않는 routine_check_id(404)
                
                ```jsx
                HTTP/1.1 404 Not Found
                
                {
                  "timestamp": "2025-04-12T09:15:00Z",
                  "statusCode": 404,
                  "success": false,
                  "error": "ROUTINE_CHECK_NOT_FOUND",
                  "message": "해당 루틴 기록이 존재하지 않습니다.",
                  "data": null
                }
                ```
                
            - 기타(500)
    


### 3. ViewModel 목록 및 상태 변수

#### 전체 ViewModel 클래스 목록
- WalkCompleteViewModel
- DogViewModel
- DogBreedSearchViewModel
- RegisterDogViewModel
- ProfileViewModel
- RouteSelectionViewModel
- SelectWaypointViewModel
- WalkHistoryViewModel
- RoutineViewModel
- StartWalkViewModel
- RouteWalkViewModel
- RecommendCourseViewModel
- LoginViewModel
- AccountDeletionViewModel
- PastRoutesViewModel
- NearbyTrailsViewModel

#### 주요 ViewModel별 상태(@Published) 변수 표
| ViewModel | 상태 변수 목록 |
| --- | --- |
| WalkHistoryViewModel | selectedDate, currentMonth, walkDates, isLoadingDates, dateError, walkRecords, isLoadingRecords, recordsError, selectedWalkDetail, isLoadingDetail, detailError |
| StartWalkViewModel | smokingZones, dogPlaces, centerCoordinate, zoomLevel, pathCoordinates, distance, duration, calories, isWalking, isPaused, userLocation, showPermissionAlert, showLocationErrorAlert, locationErrorMessage 등 |
| DogViewModel | dogs, mainDog, selectedDog, selectedDogName, dogDetail, walkRecords 등 |
| RegisterDogViewModel | name, gender, breed, dateOfBirth, weight, isNeutered, hasPatellarLuxationSurgery, profileImage, selectedImageData, isLoading, errorMessage, isRegistrationComplete 등 |
| ProfileViewModel | userInfo, isLoading, errorMessage, rawResponse |
| WalkCompleteViewModel | distance, duration, calories, walkDate, pathCoordinates, centerCoordinate, zoomLevel, dangerCoordinates, isLoading, errorMessage |
| RoutineViewModel | (루틴 관련 상태 변수) |
| LoginViewModel | (로그인 관련 상태 변수) |
| ... | ... |

#### ViewModel별 상태 변수의 특징
- 데이터, 로딩, 에러, 선택 상태 등 뷰에 필요한 모든 상태를 @Published로 관리
- 대부분 비동기 네트워크 응답 결과를 받아 상태를 갱신

---

### 5. 중복 API 함수 구체 사례 분석

| 함수명 | 구현 위치 | 주요 호출 ViewModel/Service | 내부 호출/역할 | 중복/유사 구현 특징 |
|---|---|---|---|---|
| fetchUserInfo | ProfileTabView.swift | ProfileViewModel | 사용자 정보 API 직접 호출 | 다른 ViewModel(예: LoginViewModel 등)에서도 유사 API 호출 함수 존재 가능성 있음 |
| loadWalkRecords | WalkHistoryViewModel.swift | WalkHistoryViewModel | WalkService.shared.fetchWalkRecords(date:) 호출 | 날짜별 산책 기록 조회, DogViewModel 등에서도 유사 기능 구현 |
| fetchWalkRecords | WalkService.swift, DogService.swift, DogViewModel.swift, AccountDeletionConfirmView.swift | WalkHistoryViewModel, DogViewModel, AccountDeletionConfirmView 등 | 날짜/반려견별 산책 기록 API 호출 | Service 계층에서 함수명/파라미터 다르게 중복 구현, ViewModel에서 각각 호출 및 결과 처리 |
| fetchDogs | DogService.swift, DogViewModel.swift, DogSelectionView.swift, ProfileTabView.swift 등 | DogViewModel, 여러 View | 반려견 목록 조회 | DogService/DogViewModel에 각각 구현, 여러 View에서 반복 호출 |
| fetchDogDetail | DogService.swift, DogViewModel.swift, ProfileTabView.swift 등 | DogViewModel, ProfileTabView 등 | 반려견 상세 정보 조회 | Service/Protocol/ViewModel에 중복 구현, async/await 및 Combine 혼재 |

#### 상세 분석
- **fetchUserInfo**: ProfileViewModel에서 직접 구현되어 있고, 다른 ViewModel에서도 유사하게 사용자 정보 API를 호출하는 함수가 존재할 수 있음.
- **loadWalkRecords / fetchWalkRecords**: WalkHistoryViewModel, DogViewModel, AccountDeletionConfirmView 등에서 각각 날짜별/반려견별 산책 기록을 불러오는 함수가 중복 구현되어 있음. Service 계층(DogService, WalkService)에서도 함수명이 다르거나 파라미터가 다름.
- **fetchDogs**: DogService와 DogViewModel에 각각 존재하며, 여러 View에서 반복적으로 호출됨. 내부적으로 DogService의 fetchDogs를 ViewModel에서 래핑해서 사용하는 구조.
- **fetchDogDetail**: DogService, DogViewModel, ProfileTabView 등에서 중복적으로 구현되어 있음. async/await와 Combine Publisher 방식이 혼재되어 있음.

#### 개선 제안
- Service/Repository 계층에서 공통 API 함수 시그니처 및 파라미터 통일, ViewModel에서는 최대한 래핑 없이 Service만 호출하도록 구조 단순화
- async/await와 Combine Publisher 혼용 대신 일관된 비동기 처리 방식 채택
- 중복 함수는 하나로 통합하고, 파라미터로 분기 처리(예: 날짜/반려견ID 등)

---

### 4. API 통신 함수 중복 여부 및 구조

#### 네트워크 호출 방식
- 대부분 ViewModel에서 직접 NetworkManager 또는 Service 객체의 메서드를 호출
- NetworkManager를 직접 사용하는 경우도 있고, 각 ViewModel/Service에서 별도 API 호출 함수가 구현된 경우도 있음
- 예시: ProfileTabView.swift에서 NetworkManager.shared.performAPIRequest 직접 호출

#### 중복 구현 구체 사례
- 예시1: 사용자 정보 조회 (ProfileViewModel, LoginViewModel 등에서 각각 별도의 fetchUserInfo/유사 함수 구현)
- 예시2: 산책 기록 조회 (WalkHistoryViewModel, DogViewModel 등에서 각각 loadWalkRecords, fetchWalkRecords 등 유사 함수 구현)
- 예시3: 반려견 정보 조회 (DogViewModel, RegisterDogViewModel 등에서 fetchDogs, fetchDogDetail 등 유사 함수 구현)
- 네트워크 호출 패턴(로딩 상태 관리, 에러 처리, 파싱 등)이 여러 ViewModel/Service에서 반복적으로 등장함

#### 개선 포인트
- 공통 API 호출 패턴을 하나의 Service/Repository 계층으로 더 추상화하면 중복 최소화 가능
- 에러 처리, 로딩 상태 관리, 응답 파싱 등을 통합 관리하면 유지보수성 향상

---

### 5. 중복 API 함수 구체 사례 분석

| 함수명 | 구현 위치 | 주요 호출 ViewModel/Service | 내부 호출/역할 | 중복/유사 구현 특징 |
|---|---|---|---|---|
| fetchUserInfo | ProfileTabView.swift | ProfileViewModel | 사용자 정보 API 직접 호출 | 다른 ViewModel(예: LoginViewModel 등)에서도 유사 API 호출 함수 존재 가능성 있음 |
| loadWalkRecords | WalkHistoryViewModel.swift | WalkHistoryViewModel | WalkService.shared.fetchWalkRecords(date:) 호출 | 날짜별 산책 기록 조회, DogViewModel 등에서도 유사 기능 구현 |
| fetchWalkRecords | WalkService.swift, DogService.swift, DogViewModel.swift, AccountDeletionConfirmView.swift | WalkHistoryViewModel, DogViewModel, AccountDeletionConfirmView 등 | 날짜/반려견별 산책 기록 API 호출 | Service 계층에서 함수명/파라미터 다르게 중복 구현, ViewModel에서 각각 호출 및 결과 처리 |
| fetchDogs | DogService.swift, DogViewModel.swift, DogSelectionView.swift, ProfileTabView.swift 등 | DogViewModel, 여러 View | 반려견 목록 조회 | DogService/DogViewModel에 각각 구현, 여러 View에서 반복 호출 |
| fetchDogDetail | DogService.swift, DogViewModel.swift, ProfileTabView.swift 등 | DogViewModel, ProfileTabView 등 | 반려견 상세 정보 조회 | Service/Protocol/ViewModel에 중복 구현, async/await 및 Combine 혼재 |

#### 상세 분석
- **fetchUserInfo**: ProfileViewModel에서 직접 구현되어 있고, 다른 ViewModel에서도 유사하게 사용자 정보 API를 호출하는 함수가 존재할 수 있음.
- **loadWalkRecords / fetchWalkRecords**: WalkHistoryViewModel, DogViewModel, AccountDeletionConfirmView 등에서 각각 날짜별/반려견별 산책 기록을 불러오는 함수가 중복 구현되어 있음. Service 계층(DogService, WalkService)에서도 함수명이 다르거나 파라미터가 다름.
- **fetchDogs**: DogService와 DogViewModel에 각각 존재하며, 여러 View에서 반복적으로 호출됨. 내부적으로 DogService의 fetchDogs를 ViewModel에서 래핑해서 사용하는 구조.
- **fetchDogDetail**: DogService, DogViewModel, ProfileTabView 등에서 중복적으로 구현되어 있음. async/await와 Combine Publisher 방식이 혼재되어 있음.

#### 개선 제안
- Service/Repository 계층에서 공통 API 함수 시그니처 및 파라미터 통일, ViewModel에서는 최대한 래핑 없이 Service만 호출하도록 구조 단순화
- async/await와 Combine Publisher 혼용 대신 일관된 비동기 처리 방식 채택
- 중복 함수는 하나로 통합하고, 파라미터로 분기 처리(예: 날짜/반려견ID 등)

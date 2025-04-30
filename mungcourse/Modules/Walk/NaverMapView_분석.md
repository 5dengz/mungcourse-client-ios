# NaverMapView & StartWalkView 코드 상세 분석

## 1. NaverMapView 동작 및 파라미터

### 주요 역할
- 네이버 지도를 SwiftUI에서 사용하기 위한 UIViewRepresentable 래퍼
- 위치 추적, 경로 표시, 사용자 위치 마커, 커스텀 이펙트 등 지도 관련 UI/UX 제공

### 주요 파라미터
- `@Binding var centerCoordinate: NMGLatLng` : 지도 중심 좌표
- `@Binding var zoomLevel: Double` : 지도 줌 레벨
- `@Binding var pathCoordinates: [NMGLatLng]` : 경로(Polyline) 좌표 배열
- `@Binding var userLocation: NMGLatLng?` : 사용자 위치
- `var showUserLocation: Bool = true` : 현위치 버튼 및 오버레이 표시 여부
- `var trackingMode: NMFMyPositionMode = .direction` : 위치 추적 모드(.disabled, .normal, .direction 등)
- `var onMapTapped: ((NMGLatLng) -> Void)?` : 지도 탭 이벤트 콜백
- `var onUserLocationUpdated: ((NMGLatLng) -> Void)?` : 사용자 위치 갱신 콜백

### 주요 동작
- makeUIView에서 지도 초기화, 버튼 위치 조정, 커스텀 마커/이펙트 추가, 경로 오버레이 생성
- updateUIView에서 바인딩 값 변화에 따라 지도 상태/마커/경로 오버레이 갱신
- showUserLocation, trackingMode 파라미터를 실제 지도에 반영
- Coordinator를 통해 지도 이벤트 및 오버레이 관리

---

## 2. StartWalkView 동작 및 파라미터

### 주요 역할
- 산책 시작/진행/종료 UI 및 상태 관리
- NaverMapView를 포함하여 지도와 경로, 현위치, 컨트롤러 패널 등 표시
- 산책 데이터(거리, 시간, 칼로리 등) 표시 및 산책 세션 업로드

### 주요 변수 및 상태
- `@StateObject private var viewModel = StartWalkViewModel()` : 산책 상태/로직 관리 뷰모델
- `@State private var showCompleteAlert = false` : 산책 완료 알림
- `@State private var completedSession: WalkSession? = nil` : 완료된 세션 정보
- `@State private var effectScale: CGFloat = 0.5` : 이펙트 애니메이션용
- `@State private var effectOpacity: Double = 1.0` : 이펙트 애니메이션용

### 주요 동작
- NaverMapView에 centerCoordinate, zoomLevel, pathCoordinates, userLocation 등 뷰모델의 상태를 바인딩
- showUserLocation은 true, trackingMode는 .direction으로 고정
- WalkControllerView를 통해 산책 시작/일시정지/재개/종료 컨트롤
- 산책 종료 시 WalkSession 업로드 및 완료 알림
- 위치 권한/에러 등 다양한 Alert 처리

---

## 3. NaverMapView <-> StartWalkView 연동 구조
- StartWalkView는 NaverMapView의 모든 주요 파라미터를 뷰모델의 상태와 바인딩하여 실시간 지도 반영
- NaverMapView는 파라미터 값에 따라 지도 중심, 줌, 경로, 현위치, 버튼, 오버레이 등을 동적으로 갱신
- 산책 상태 변화(경로 추가, 위치 이동 등)가 곧바로 지도에 반영됨

---

## 4. 참고
- NaverMapView의 showUserLocation, trackingMode는 실제 지도에 반영되도록 구현되어 있음
- 커스텀 마커(발바닥), 이펙트(애니메이션), 경로 오버레이 등 지도 UI 커스터마이징이 적용됨
- StartWalkView는 산책 전체 UI/UX의 컨테이너 역할을 하며, 지도와 컨트롤러, 헤더, 알림 등을 통합 관리함

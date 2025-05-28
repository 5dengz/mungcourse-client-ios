import SwiftUI
import NMapsMap

struct WalkCompleteView: View {
    @StateObject private var viewModel = WalkCompleteViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dogVM: DogViewModel
    @State private var isGoHome = false
    
    var onForceDismiss: (() -> Void)? = nil
    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더 (날짜 데이터 ViewModel에서 사용)
            // DogViewModel 상태 로깅
            let _ = print("📱 [WalkCompleteView] DogVM 상태: selectedDog=\(dogVM.selectedDog?.name ?? "nil"), mainDog=\(dogVM.mainDog?.name ?? "nil")")
            
            WalkCompleteHeader(walkDate: viewModel.walkDate, onClose: {
                dismiss()
            }, dogViewModel: dogVM) // DogViewModel을 매개변수로 직접 전달
            .padding(.bottom, 8)

            ScrollView {
                // 산책 경로 지도+통계 통합 뷰
                WalkRouteSummaryView(
                    coordinates: viewModel.pathCoordinates,
                    distance: viewModel.distance,
                    duration: viewModel.duration,
                    calories: viewModel.calories,
                    isLoading: false,
                    errorMessage: nil,
                    emptyMessage: "저장된 경로 정보가 없습니다",
                    boundingBox: nil,
                    mapHeight: 300
                )
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("pointwhite"))
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }

            Spacer(minLength: 0)

            // 홈으로 이동 버튼
            CommonFilledButton(title: "홈으로 이동", action: {
                print("🌟 [WalkCompleteView] 홈으로 이동 버튼 클릭 - 화면 해제 시작")
                
                // onForceDismiss 콜백이 있는 경우
                if let dismissAction = onForceDismiss {
                    print("🌟 [WalkCompleteView] onForceDismiss 콜백 발견, 즉시 실행")
                    
                    // 즉시 콜백 실행 - 지연 없이
                    dismissAction()  // 이 콜백은 StartWalkView에서 수신하여 모든 화면 해제 처리
                } else {
                    // 콜백이 없는 경우 보호 조치
                    print("🌟 [WalkCompleteView] onForceDismiss 콜백 없음, 현재 화면만 dismiss() 실행")
                    dismiss()  // 이 경우는 발생하지 않아야 하지만 보호 조치로 추가
                }
            })
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color("pointwhite").ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    // 사용자 정의 이니셜라이저로 ViewModel 초기화 가능
    init(walkData: WalkSession? = nil, onForceDismiss: (() -> Void)? = nil) {
        // WalkSession 데이터 로깅
        if let session = walkData {
            print("📱 [WalkCompleteView] WalkSession 데이터: distance=\(session.distance), duration=\(session.duration)")
        } else {
            print("📱 [WalkCompleteView] WalkSession 데이터: nil")
        }
        
        // WalkSession에서 필요한 데이터 추출
        let sessionData: WalkSessionData? = walkData.map { session in
            // WalkSession에서 WalkSessionData로 변환
            WalkSessionData(
                distance: session.distance,
                duration: Int(session.duration),
                date: session.endTime,
                coordinates: session.path
            )
        }
        
        let vm = WalkCompleteViewModel(walkData: sessionData)
        _viewModel = StateObject(wrappedValue: vm)
        self.onForceDismiss = onForceDismiss
    }
}
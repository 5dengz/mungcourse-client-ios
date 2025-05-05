import Foundation
import Combine
import SwiftUI
import NMapsGeometry

class PastRoutesViewModel: ObservableObject {
    // 상태 관리를 위한 열거형
    enum LoadingState {
        case idle
        case loading
        case loaded(Walk)
        case error(Error)
    }
    
    // 출판(Publisher) 속성
    @Published var state: LoadingState = .idle
    @Published var recentWalk: Walk?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 초기화 시 최근 산책 데이터를 자동으로 로드
        loadRecentWalk()
    }
    
    // 최근 산책 데이터 로드
    func loadRecentWalk() {
        isLoading = true
        state = .loading
        errorMessage = nil
        
        WalkService.shared.fetchRecentWalk()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                
                self.isLoading = false
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.state = .error(error)
                    self.errorMessage = "산책 기록을 불러오는 데 실패했습니다: \(error.localizedDescription)"
                    print("산책 데이터 로드 오류: \(error)")
                }
            } receiveValue: { [weak self] walk in
                guard let self = self else { return }
                
                self.recentWalk = walk
                self.state = .loaded(walk)
            }
            .store(in: &cancellables)
    }
    
    // 네이버 맵용 좌표 배열 변환
    func getNaverMapCoordinates() -> [NMGLatLng] {
        guard let walk = recentWalk, !walk.gpsData.isEmpty else {
            return []
        }
        
        return walk.gpsData.map { coordinate in
            NMGLatLng(lat: coordinate.lat, lng: coordinate.lng)
        }
    }
    
    // 네이버 맵 중심 좌표 구하기
    func getMapCenterCoordinate() -> NMGLatLng? {
        guard let walk = recentWalk, let firstPoint = walk.gpsData.first else {
            return nil
        }
        
        return NMGLatLng(lat: firstPoint.lat, lng: firstPoint.lng)
    }
    
    // 지도 경계(bounds) 계산하기
    func calculateMapBounds() -> NMGLatLngBounds? {
        guard let walk = recentWalk, !walk.gpsData.isEmpty else {
            return nil
        }
        
        let coordinates = walk.gpsData
        guard let firstCoord = coordinates.first else { return nil }
        
        var minLat = firstCoord.lat
        var maxLat = firstCoord.lat
        var minLng = firstCoord.lng
        var maxLng = firstCoord.lng
        
        for coord in coordinates {
            minLat = min(minLat, coord.lat)
            maxLat = max(maxLat, coord.lat)
            minLng = min(minLng, coord.lng)
            maxLng = max(maxLng, coord.lng)
        }
        
        return NMGLatLngBounds(southWest: NMGLatLng(lat: minLat, lng: minLng),
                               northEast: NMGLatLng(lat: maxLat, lng: maxLng))
    }
}
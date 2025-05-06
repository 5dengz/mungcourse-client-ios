import Foundation
import Combine
import NMapsMap

class WalkService {
    static let shared = WalkService()
    private init() {}
    
    private let baseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? "https://api.mungcourse.com"
    
    // 최근 산책 기록 가져오기
    func fetchRecentWalk() -> AnyPublisher<WalkDTO, Error> {
        guard let url = URL(string: "\(baseURL)/v1/walks/recent") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return Future<WalkDTO, Error> { promise in
            
            NetworkManager.shared.performAPIRequest(request) { data, response, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    promise(.failure(URLError(.badServerResponse)))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    promise(.failure(URLError(.badServerResponse)))
                    return
                }
                
                guard let data = data else {
                    promise(.failure(URLError(.zeroByteResource)))
                    return
                }
                
                do {
                    let walkResponse = try JSONDecoder().decode(WalkResponse.self, from: data)
                    
                    // data가 null인 경우 처리
                    guard let walkData = walkResponse.data else {
                        let noDataError = NSError(
                            domain: "com.mungcourse.error",
                            code: 404,
                            userInfo: [NSLocalizedDescriptionKey: "산책 기록이 없습니다"]
                        )
                        promise(.failure(noDataError))
                        return
                    }
                    
                    promise(.success(walkData.toWalkDTO()))
                } catch {
                    print("JSON 디코딩 오류: \(error)")
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 산책 기록 저장하기
    func uploadWalkSession(_ session: WalkSession, dogIds: [Int]) -> AnyPublisher<Bool, Error> {
        guard let url = URL(string: "\(baseURL)/v1/walks") else {
            print("❌ 산책 데이터 업로드 실패: 잘못된 URL")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = session.toAPIDictionary(dogIds: dogIds)
        print("📤 산책 데이터 업로드 요청 Dictionary: \(body)")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            
            // 요청 본문 JSON 문자열로 출력
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 산책 데이터 요청 본문(JSON): \(jsonString)")
            }
        } catch {
            print("❌ 산책 데이터 JSON 변환 실패: \(error)")
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return Future<Bool, Error> { promise in
            NetworkManager.shared.performAPIRequest(request) { data, response, error in
                if let error = error {
                    print("❌ 산책 데이터 업로드 실패: \(error)")
                    print("❌ 에러 상세: \(error.localizedDescription)")
                    promise(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ 산책 데이터 업로드 실패: 응답 없음")
                    promise(.failure(URLError(.badServerResponse)))
                    return
                }
                
                // 상태 코드와 함께 응답 헤더 출력
                print("🔄 응답 상태 코드: \(httpResponse.statusCode)")
                print("🔄 응답 헤더: \(httpResponse.allHeaderFields)")
                
                // 응답 데이터 출력
                if let data = data {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("📥 산책 데이터 응답 본문: \(responseString)")
                    }
                    
                    if (200...299).contains(httpResponse.statusCode) {
                        do {
                            // 성공 응답 파싱
                            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                                print("✅ 산책 데이터 업로드 성공: \(json)")
                                
                                if let success = json["success"] as? Bool, success {
                                    promise(.success(true))
                                } else {
                                    print("⚠️ 산책 데이터 업로드 응답 - success 필드가 false 또는 없음")
                                    promise(.success(false))
                                }
                            } else {
                                print("❌ 산책 데이터 업로드 실패: 응답 형식 불일치")
                                promise(.failure(URLError(.cannotParseResponse)))
                            }
                        } catch {
                            print("❌ 산책 데이터 업로드 응답 파싱 실패: \(error)")
                            promise(.failure(error))
                        }
                    } else {
                        print("❌ 산책 데이터 업로드 실패: 상태 코드 \(httpResponse.statusCode)")
                        if let errorString = String(data: data, encoding: .utf8) {
                            print("❌ 에러 응답: \(errorString)")
                        }
                        promise(.failure(URLError(.badServerResponse)))
                    }
                } else {
                    print("❌ 산책 데이터 업로드 실패: 응답 데이터 없음")
                    promise(.failure(URLError(.zeroByteResource)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 추천 경로 가져오기
    func fetchRecommendRoute(currentLat: Double, currentLng: Double, dogPlaceIds: [Int]) -> AnyPublisher<(coordinates: [NMGLatLng], totalDistance: Double, estimatedTime: Int), Error> {
        guard let url = URL(string: "\(baseURL)/v1/walks/recommend") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "currentLat": currentLat,
            "currentLng": currentLng,
            "dogPlaceIds": dogPlaceIds
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return Future<(coordinates: [NMGLatLng], totalDistance: Double, estimatedTime: Int), Error> { promise in
            NetworkManager.shared.performAPIRequest(request) { data, response, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode),
                      let data = data else {
                    promise(.failure(URLError(.badServerResponse)))
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let coordsArr = json["coordinates"] as? [[Double]],
                       let totalDistance = json["totalDistance"] as? Double,
                       let estimatedTime = json["estimatedTime"] as? Int {
                        let coordinates = coordsArr.map { NMGLatLng(lat: $0[0], lng: $0[1]) }
                        promise(.success((coordinates: coordinates, totalDistance: totalDistance, estimatedTime: estimatedTime)))
                    } else {
                        promise(.failure(URLError(.cannotParseResponse)))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - History 관련 API
    
    // 특정 연도와 월의 산책 날짜 조회 (달력 표시용)
    func fetchWalkDates(year: Int, month: Int) -> AnyPublisher<[WalkDateResponse], Error> {
        let yearMonth = String(format: "%04d-%02d", year, month)
        guard let url = URL(string: "\(baseURL)/v1/walks/calender?yearAndMonth=\(yearMonth)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return NetworkManager.shared.requestWithTokenPublisher(request)
    .tryMap { data, response -> Data in
        if let httpResponse = response as? HTTPURLResponse {
            print("[fetchWalkDates] statusCode: \(httpResponse.statusCode)")
        }
        if let bodyString = String(data: data, encoding: .utf8) {
            print("[fetchWalkDates] response body: \(bodyString)")
        }
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }
    .decode(type: WalkDatesResponse.self, decoder: JSONDecoder())
    .map { $0.data ?? [] }
    .eraseToAnyPublisher()
    }
    
    // 특정 날짜의 산책 기록 목록 조회
    func fetchWalkRecords(date: Date) -> AnyPublisher<[WalkRecord], Error> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        guard let url = URL(string: "\(baseURL)/v1/walks?date=\(dateString)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return NetworkManager.shared.requestWithTokenPublisher(request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: WalkRecordsResponse.self, decoder: JSONDecoder())
            .map { $0.data ?? [] }
            .eraseToAnyPublisher()
    }
    
    // 산책 기록 상세 조회
    func fetchWalkDetail(walkId: Int) -> AnyPublisher<WalkDetail, Error> {
        guard let url = URL(string: "\(baseURL)/v1/walks/\(walkId)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return NetworkManager.shared.requestWithTokenPublisher(request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: WalkDetailResponse.self, decoder: JSONDecoder())
            .compactMap { $0.data }
            .eraseToAnyPublisher()
    }
}
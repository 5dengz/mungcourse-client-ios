import Foundation
import NMapsMap
import SwiftData

/// Represents a completed walk session with tracking data
@Model
class WalkSession {
    var id: UUID
    var startTime: Date
    var endTime: Date
    var duration: TimeInterval // in seconds
    var distance: Double // in kilometers
    var calories: Double // in kcal
    var averageSpeed: Double // in km/h
    
    // SwiftData doesn't directly support NMGLatLng, so we need to transform the data
    var pathLatitudes: [Double]
    var pathLongitudes: [Double]
    
    // Transient property for the full path
    @Transient
    var path: [NMGLatLng] {
        get {
            var result: [NMGLatLng] = []
            for i in 0..<min(pathLatitudes.count, pathLongitudes.count) {
                result.append(NMGLatLng(lat: pathLatitudes[i], lng: pathLongitudes[i]))
            }
            return result
        }
        set {
            pathLatitudes = newValue.map { $0.lat }
            pathLongitudes = newValue.map { $0.lng }
        }
    }
    
    init(id: UUID, startTime: Date, endTime: Date, duration: TimeInterval, distance: Double, calories: Double, path: [NMGLatLng], averageSpeed: Double) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.distance = distance
        self.calories = calories
        self.averageSpeed = averageSpeed
        
        self.pathLatitudes = path.map { $0.lat }
        self.pathLongitudes = path.map { $0.lng }
    }
    
    // Format duration as "HH:MM:SS"
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

extension WalkSession {
    func toAPIDictionary(dogIds: [Int]) -> [String: Any] {
        [
            "distanceKm": distance,
            "durationSec": Int(duration),
            "calories": Int(calories),
            "startedAt": ISO8601DateFormatter().string(from: startTime),
            "endedAt": ISO8601DateFormatter().string(from: endTime),
            "routeRating": 0, // 기본값 0으로 설정
            "dogIds": dogIds,
            "gpsData": Array(zip(pathLatitudes, pathLongitudes)).map { ["lat": $0.0, "lng": $0.1] }
        ]
    }
}
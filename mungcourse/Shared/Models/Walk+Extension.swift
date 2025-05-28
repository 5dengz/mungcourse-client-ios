import Foundation

extension Walk {
    func toWalkDTO() -> WalkDTO {
        return WalkDTO(
            id: self.id,
            distanceKm: self.distanceKm,
            durationSec: self.durationSec,
            calories: self.calories,
            startedAt: self.startedAt,
            endedAt: self.endedAt,
            routeRating: Double(self.routeRating),
            dogIds: self.dogIds,
            gpsData: self.gpsData.map { GpsPoint(lat: $0.lat, lng: $0.lng) }
        )
    }
}

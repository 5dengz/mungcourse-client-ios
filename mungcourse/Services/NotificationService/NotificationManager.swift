import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    /// 알림 권한을 요청합니다.
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("알림 권한 요청 에러: \(error.localizedDescription)")
            }
            if !granted {
                print("알림 권한이 거부되었습니다.")
            }
        }
    }

    /// 받은 RoutineData 배열을 기반으로 알림을 스케줄합니다.
    func scheduleNotifications(for routines: [RoutineData]) {
        // 기존 예약된 알림 제거
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")

        routines.forEach { data in
            let dateTimeString = "\(data.date) \(data.alarmTime)"
            guard let date = formatter.date(from: dateTimeString) else {
                print("날짜 파싱 실패: \(dateTimeString)")
                return
            }
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let content = UNMutableNotificationContent()
            content.title = "루틴 알림"
            content.body = "\(data.name)을(를) 수행할 시간이에요!"
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "\(data.routineId)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("알림 추가 에러: \(error.localizedDescription)")
                }
            }
        }
    }
} 
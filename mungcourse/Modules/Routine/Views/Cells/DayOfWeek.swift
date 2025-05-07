// 요일 enum 및 한글 변환 확장
import Foundation

public enum DayOfWeek: String, CaseIterable, Identifiable {
    case mon = "월", tue = "화", wed = "수", thu = "목", fri = "금", sat = "토", sun = "일"
    public var id: String { rawValue }
    public var shortKor: String { rawValue }
}

extension DayOfWeek {
    static var today: DayOfWeek {
        let weekday = Calendar.current.component(.weekday, from: Date())
        switch weekday {
        case 1: return .sun
        case 2: return .mon
        case 3: return .tue
        case 4: return .wed
        case 5: return .thu
        case 6: return .fri
        case 7: return .sat
        default: return .mon
        }
    }
    static var monday: DayOfWeek { .mon }
    var apiValue: String {
        switch self {
        case .mon: return "MON"
        case .tue: return "TUE"
        case .wed: return "WED"
        case .thu: return "THU"
        case .fri: return "FRI"
        case .sat: return "SAT"
        case .sun: return "SUN"
        }
    }
}

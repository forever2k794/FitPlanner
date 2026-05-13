import Foundation

enum WorkoutFocusType: String, CaseIterable, Identifiable, Codable, Hashable {
    case recommended
    case push
    case pull
    case legs
    case fullBody
    case chest
    case back
    case shoulders
    case arms
    case core
    case custom

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .recommended:
            return "自動推薦"
        case .push:
            return "推"
        case .pull:
            return "拉"
        case .legs:
            return "腿"
        case .fullBody:
            return "全身"
        case .chest:
            return "胸部"
        case .back:
            return "背部"
        case .shoulders:
            return "肩部"
        case .arms:
            return "手臂"
        case .core:
            return "核心"
        case .custom:
            return "自訂"
        }
    }
}

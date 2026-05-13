import Foundation

enum TrainingStyle: String, CaseIterable, Identifiable, Codable, Hashable {
    case strength
    case hypertrophy
    case endurance
    case recovery
    case custom

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .strength:
            return "力量"
        case .hypertrophy:
            return "肌肥大"
        case .endurance:
            return "耐力"
        case .recovery:
            return "輕量恢復"
        case .custom:
            return "自訂"
        }
    }
}

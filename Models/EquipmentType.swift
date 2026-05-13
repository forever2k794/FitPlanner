import Foundation

enum EquipmentType: String, CaseIterable, Identifiable, Codable, Hashable {
    case barbell
    case dumbbell
    case machine
    case cable
    case bodyweight
    case smithMachine
    case kettlebell

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .barbell:
            return "槓鈴"
        case .dumbbell:
            return "啞鈴"
        case .machine:
            return "機械"
        case .cable:
            return "繩索"
        case .bodyweight:
            return "徒手"
        case .smithMachine:
            return "史密斯機"
        case .kettlebell:
            return "壺鈴"
        }
    }
}

import Foundation

enum TrainingSplitType: String, CaseIterable, Codable, Hashable {
    case fullBody
    case fullBodyA
    case fullBodyB
    case fullBodyC
    case upperPush
    case upperPull
    case lowerBody
    case fullBodyVolume
    case push
    case pull
    case legs
    case recovery

    var displayName: String {
        switch self {
        case .fullBody:
            return "全身基礎"
        case .fullBodyA:
            return "全身 A"
        case .fullBodyB:
            return "全身 B"
        case .fullBodyC:
            return "全身 C"
        case .upperPush:
            return "上肢推"
        case .upperPull:
            return "上肢拉"
        case .lowerBody:
            return "下肢"
        case .fullBodyVolume:
            return "全身容量"
        case .push:
            return "推"
        case .pull:
            return "拉"
        case .legs:
            return "腿"
        case .recovery:
            return "恢復"
        }
    }
}

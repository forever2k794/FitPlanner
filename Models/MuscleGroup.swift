import Foundation

enum MuscleGroup: String, CaseIterable, Identifiable, Codable, Hashable {
    case chest
    case back
    case shoulders
    case biceps
    case triceps
    case quads
    case hamstrings
    case glutes
    case calves
    case core

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .chest:
            return "胸部"
        case .back:
            return "背部"
        case .shoulders:
            return "肩部"
        case .biceps:
            return "二頭肌"
        case .triceps:
            return "三頭肌"
        case .quads:
            return "股四頭肌"
        case .hamstrings:
            return "腿後側"
        case .glutes:
            return "臀部"
        case .calves:
            return "小腿"
        case .core:
            return "核心"
        }
    }
}

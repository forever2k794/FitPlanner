import Foundation

struct PlanGenerationExplanation: Hashable, Codable {
    var summary: String
    var splitReason: String
    var historyReference: String
    var exerciseReasons: [ExercisePlanExplanation]
}

struct ExercisePlanExplanation: Identifiable, Hashable, Codable {
    let id: UUID
    var exerciseName: String
    var reason: String
    var adjustment: PlanAdjustmentType

    init(
        id: UUID = UUID(),
        exerciseName: String,
        reason: String,
        adjustment: PlanAdjustmentType
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.reason = reason
        self.adjustment = adjustment
    }
}

enum PlanAdjustmentType: String, Hashable, Codable {
    case progressed
    case maintained
    case reduced
    case defaulted

    var displayName: String {
        switch self {
        case .progressed:
            return "加重"
        case .maintained:
            return "維持"
        case .reduced:
            return "降載"
        case .defaulted:
            return "預設"
        }
    }
}

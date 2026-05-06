import Foundation

enum ExerciseProgressionCategory: String, Codable, Hashable {
    case primary
    case accessory
    case bodyweightCore
}

enum ExerciseProgressionRule {
    static let primaryWeightIncrease: Double = 2.5
    static let accessoryWeightIncrease: Double = 1
    static let fatigueLoadMultiplier: Double = 0.95
    static let minimumTargetSets: Int = 2
    static let defaultPrimarySets: Int = 4
    static let defaultAccessorySets: Int = 3
    static let defaultCoreSets: Int = 3
    static let defaultPrimaryReps: Int = 6
    static let defaultAccessoryReps: Int = 10
    static let defaultCoreReps: Int = 15
    static let defaultTargetRPE: Double = 8
    static let defaultTargetRIR: Int = 2
    static let fatigueTargetRPE: Double = 7.5
    static let fatigueTargetRIR: Int = 3

    static func category(for exerciseName: String) -> ExerciseProgressionCategory {
        switch exerciseName {
        case "深蹲", "臥推", "硬舉", "肩推", "划船":
            return .primary
        case "腹部訓練":
            return .bodyweightCore
        default:
            return .accessory
        }
    }

    static func defaultWeight(for exerciseName: String) -> Double {
        switch exerciseName {
        case "深蹲":
            return 80
        case "臥推":
            return 60
        case "硬舉":
            return 100
        case "肩推":
            return 20
        case "划船":
            return 55
        case "滑輪下拉":
            return 50
        case "腿推":
            return 140
        case "腿彎舉":
            return 40
        case "側平舉":
            return 8
        case "腹部訓練":
            return 0
        default:
            return 20
        }
    }

    static func defaultSets(for category: ExerciseProgressionCategory) -> Int {
        switch category {
        case .primary:
            return defaultPrimarySets
        case .accessory:
            return defaultAccessorySets
        case .bodyweightCore:
            return defaultCoreSets
        }
    }

    static func defaultReps(for category: ExerciseProgressionCategory) -> Int {
        switch category {
        case .primary:
            return defaultPrimaryReps
        case .accessory:
            return defaultAccessoryReps
        case .bodyweightCore:
            return defaultCoreReps
        }
    }
}

import Foundation

struct Exercise: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var primaryMuscleGroup: String
    var equipment: String
    var note: String
    var primaryMuscleGroups: [MuscleGroup]
    var secondaryMuscleGroups: [MuscleGroup]
    var equipmentTypes: [EquipmentType]
    var supportedFocusTypes: [WorkoutFocusType]
    var supportedTrainingStyles: [TrainingStyle]
    var isCompound: Bool
    var defaultSets: Int
    var defaultReps: Int

    init(
        id: UUID = UUID(),
        name: String,
        primaryMuscleGroup: String,
        equipment: String,
        note: String = "",
        primaryMuscleGroups: [MuscleGroup]? = nil,
        secondaryMuscleGroups: [MuscleGroup] = [],
        equipmentTypes: [EquipmentType]? = nil,
        supportedFocusTypes: [WorkoutFocusType] = [],
        supportedTrainingStyles: [TrainingStyle] = [.strength, .hypertrophy, .endurance],
        isCompound: Bool = false,
        defaultSets: Int = 3,
        defaultReps: Int = 10
    ) {
        self.id = id
        self.name = name
        self.primaryMuscleGroup = primaryMuscleGroup
        self.equipment = equipment
        self.note = note
        self.primaryMuscleGroups = primaryMuscleGroups ?? Self.inferredMuscleGroups(from: primaryMuscleGroup)
        self.secondaryMuscleGroups = secondaryMuscleGroups
        self.equipmentTypes = equipmentTypes ?? Self.inferredEquipmentTypes(from: equipment)
        self.supportedFocusTypes = supportedFocusTypes.isEmpty ? Self.inferredFocusTypes(from: primaryMuscleGroup) : supportedFocusTypes
        self.supportedTrainingStyles = supportedTrainingStyles
        self.isCompound = isCompound
        self.defaultSets = defaultSets
        self.defaultReps = defaultReps
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case primaryMuscleGroup
        case equipment
        case note
        case primaryMuscleGroups
        case secondaryMuscleGroups
        case equipmentTypes
        case supportedFocusTypes
        case supportedTrainingStyles
        case isCompound
        case defaultSets
        case defaultReps
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        primaryMuscleGroup = try container.decodeIfPresent(String.self, forKey: .primaryMuscleGroup) ?? "全身"
        equipment = try container.decodeIfPresent(String.self, forKey: .equipment) ?? "徒手"
        note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
        primaryMuscleGroups = try container.decodeIfPresent([MuscleGroup].self, forKey: .primaryMuscleGroups)
            ?? Self.inferredMuscleGroups(from: primaryMuscleGroup)
        secondaryMuscleGroups = try container.decodeIfPresent([MuscleGroup].self, forKey: .secondaryMuscleGroups) ?? []
        equipmentTypes = try container.decodeIfPresent([EquipmentType].self, forKey: .equipmentTypes)
            ?? Self.inferredEquipmentTypes(from: equipment)
        supportedFocusTypes = try container.decodeIfPresent([WorkoutFocusType].self, forKey: .supportedFocusTypes)
            ?? Self.inferredFocusTypes(from: primaryMuscleGroup)
        supportedTrainingStyles = try container.decodeIfPresent([TrainingStyle].self, forKey: .supportedTrainingStyles)
            ?? [.strength, .hypertrophy, .endurance]
        isCompound = try container.decodeIfPresent(Bool.self, forKey: .isCompound) ?? Self.inferredIsCompound(name: name)
        defaultSets = try container.decodeIfPresent(Int.self, forKey: .defaultSets) ?? 3
        defaultReps = try container.decodeIfPresent(Int.self, forKey: .defaultReps) ?? 10
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(primaryMuscleGroup, forKey: .primaryMuscleGroup)
        try container.encode(equipment, forKey: .equipment)
        try container.encode(note, forKey: .note)
    }

    private static func inferredMuscleGroups(from text: String) -> [MuscleGroup] {
        if text.contains("胸") {
            return [.chest]
        }

        if text.contains("背") {
            return [.back]
        }

        if text.contains("肩") {
            return [.shoulders]
        }

        if text.contains("二頭") {
            return [.biceps]
        }

        if text.contains("三頭") {
            return [.triceps]
        }

        if text.contains("腿後") {
            return [.hamstrings]
        }

        if text.contains("腿") || text.contains("股四") {
            return [.quads]
        }

        if text.contains("臀") {
            return [.glutes]
        }

        if text.contains("小腿") {
            return [.calves]
        }

        if text.contains("核心") || text.contains("腹") {
            return [.core]
        }

        return []
    }

    private static func inferredEquipmentTypes(from text: String) -> [EquipmentType] {
        if text.contains("槓") {
            return [.barbell]
        }

        if text.contains("啞") {
            return [.dumbbell]
        }

        if text.contains("滑輪") || text.contains("繩索") || text.contains("Cable") {
            return [.cable]
        }

        if text.contains("史密斯") {
            return [.smithMachine]
        }

        if text.contains("壺鈴") {
            return [.kettlebell]
        }

        if text.contains("徒手") || text.contains("自體") {
            return [.bodyweight]
        }

        return [.machine]
    }

    private static func inferredFocusTypes(from text: String) -> [WorkoutFocusType] {
        let muscleGroups = inferredMuscleGroups(from: text)
        var focusTypes: Set<WorkoutFocusType> = [.fullBody, .custom]

        if muscleGroups.contains(.chest) || muscleGroups.contains(.shoulders) || muscleGroups.contains(.triceps) {
            focusTypes.insert(.push)
        }

        if muscleGroups.contains(.back) || muscleGroups.contains(.biceps) {
            focusTypes.insert(.pull)
        }

        if muscleGroups.contains(.quads) || muscleGroups.contains(.hamstrings) || muscleGroups.contains(.glutes) || muscleGroups.contains(.calves) {
            focusTypes.insert(.legs)
        }

        if muscleGroups.contains(.chest) {
            focusTypes.insert(.chest)
        }

        if muscleGroups.contains(.back) {
            focusTypes.insert(.back)
        }

        if muscleGroups.contains(.shoulders) {
            focusTypes.insert(.shoulders)
        }

        if muscleGroups.contains(.biceps) || muscleGroups.contains(.triceps) {
            focusTypes.insert(.arms)
        }

        if muscleGroups.contains(.core) {
            focusTypes.insert(.core)
        }

        return Array(focusTypes)
    }

    private static func inferredIsCompound(name: String) -> Bool {
        ["深蹲", "硬舉", "臥推", "划船", "肩推", "腿推", "引體向上", "臀推"].contains { name.contains($0) }
    }
}

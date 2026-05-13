import Foundation

struct WorkoutGenerationPreference: Hashable {
    var focusType: WorkoutFocusType
    var availableEquipment: [EquipmentType]
    var trainingStyle: TrainingStyle

    init(
        focusType: WorkoutFocusType = .recommended,
        availableEquipment: [EquipmentType] = EquipmentType.allCases,
        trainingStyle: TrainingStyle = .hypertrophy
    ) {
        self.focusType = focusType
        self.availableEquipment = availableEquipment
        self.trainingStyle = trainingStyle
    }
}

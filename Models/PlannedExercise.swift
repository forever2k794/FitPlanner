import Foundation

struct PlannedExercise: Identifiable, Hashable, Codable {
    let id: UUID
    var exercise: Exercise
    var targetSets: Int
    var targetReps: Int
    var suggestedWeightInKilograms: Double
    var targetRPE: Double?
    var targetRIR: Int?

    init(
        id: UUID = UUID(),
        exercise: Exercise,
        targetSets: Int,
        targetReps: Int,
        suggestedWeightInKilograms: Double,
        targetRPE: Double? = nil,
        targetRIR: Int? = nil
    ) {
        self.id = id
        self.exercise = exercise
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.suggestedWeightInKilograms = suggestedWeightInKilograms
        self.targetRPE = targetRPE
        self.targetRIR = targetRIR
    }
}

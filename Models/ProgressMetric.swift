import Foundation

struct WeeklyProgressMetric: Identifiable, Hashable {
    let weekStartDate: Date
    let label: String
    let totalVolume: Double
    let workoutCount: Int

    var id: Date {
        weekStartDate
    }
}

struct ExercisePRMetric: Identifiable, Hashable {
    let exerciseName: String
    let weightInKilograms: Double
    let reps: Int
    let date: Date

    var id: String {
        exerciseName
    }
}

struct MuscleGroupFrequencyMetric: Identifiable, Hashable {
    let muscleGroup: String
    let trainingCount: Int

    var id: String {
        muscleGroup
    }
}

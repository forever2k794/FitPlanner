import Foundation

struct WorkoutSessionRecord: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var date: Date
    var exerciseLogs: [ExerciseLog]
    var isCompleted: Bool
    var note: String

    var totalVolume: Double {
        exerciseLogs.reduce(0) { $0 + $1.totalVolume }
    }

    var muscleGroups: [String] {
        Array(Set(exerciseLogs.map(\.exercise.primaryMuscleGroup))).sorted()
    }

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        exerciseLogs: [ExerciseLog],
        isCompleted: Bool = true,
        note: String = ""
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.exerciseLogs = exerciseLogs
        self.isCompleted = isCompleted
        self.note = note
    }
}

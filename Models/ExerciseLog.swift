import Foundation

struct ExerciseLog: Identifiable, Hashable {
    let id: UUID
    var exercise: Exercise
    var sets: [SetLog]
    var note: String

    var totalVolume: Double {
        sets.reduce(0) { $0 + $1.volume }
    }

    init(
        id: UUID = UUID(),
        exercise: Exercise,
        sets: [SetLog],
        note: String = ""
    ) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
        self.note = note
    }
}

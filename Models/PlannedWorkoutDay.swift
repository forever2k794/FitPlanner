import Foundation

struct PlannedWorkoutDay: Identifiable, Hashable {
    let id: UUID
    var date: Date
    var title: String
    var focus: String
    var plannedExercises: [PlannedExercise]

    var isRestDay: Bool {
        plannedExercises.isEmpty
    }

    init(
        id: UUID = UUID(),
        date: Date,
        title: String,
        focus: String,
        plannedExercises: [PlannedExercise]
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.focus = focus
        self.plannedExercises = plannedExercises
    }
}

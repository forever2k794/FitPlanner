import Foundation

struct GeneratedPlan: Identifiable, Hashable {
    let id: UUID
    var name: String
    var weekStartDate: Date
    var days: [PlannedWorkoutDay]

    init(
        id: UUID = UUID(),
        name: String,
        weekStartDate: Date,
        days: [PlannedWorkoutDay]
    ) {
        self.id = id
        self.name = name
        self.weekStartDate = weekStartDate
        self.days = days
    }
}

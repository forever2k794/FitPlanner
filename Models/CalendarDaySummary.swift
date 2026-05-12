import Foundation

struct CalendarDaySummary: Identifiable, Hashable {
    let date: Date
    let isInDisplayedMonth: Bool
    let hasWorkoutRecord: Bool
    let workoutTitle: String?
    let totalVolume: Double
    let completedSetCount: Int
    let hasPlannedWorkout: Bool
    let plannedTitle: String?
    let plannedFocus: String?
    let plannedExerciseCount: Int
    let isRestDay: Bool
    let isToday: Bool
    let isSelected: Bool

    var id: Date {
        date.fitPlannerStartOfDay
    }
}

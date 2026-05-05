import Foundation

protocol FitnessRepository: AnyObject {
    func fetchUserProfile() -> UserProfile
    func fetchExercises() -> [Exercise]
    func fetchWorkoutRecords() -> [WorkoutSessionRecord]
    func fetchGeneratedPlan() -> GeneratedPlan
    func saveWorkoutRecord(_ record: WorkoutSessionRecord)
    func updateWorkoutRecord(_ record: WorkoutSessionRecord)
    func plannedWorkout(on date: Date) -> PlannedWorkoutDay?
    func nextPlannedWorkout(from date: Date) -> PlannedWorkoutDay?
}

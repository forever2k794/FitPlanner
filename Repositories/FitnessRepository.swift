import Foundation

protocol FitnessRepository: AnyObject {
    func fetchUserProfile() -> UserProfile
    func fetchExercises() -> [Exercise]
    func fetchWorkoutRecords() -> [WorkoutSessionRecord]
    func fetchGeneratedPlan() -> GeneratedPlan
    func saveUserProfile(_ profile: UserProfile)
    func saveWorkoutRecord(_ record: WorkoutSessionRecord)
    func upsertWorkoutRecords(_ records: [WorkoutSessionRecord])
    func updateWorkoutRecord(_ record: WorkoutSessionRecord)
    func deleteWorkoutRecord(id: UUID)
    func canDeleteWorkoutRecord(id: UUID) -> Bool
    func canEditWorkoutRecord(id: UUID) -> Bool
    func plannedWorkout(on date: Date) -> PlannedWorkoutDay?
    func nextPlannedWorkout(from date: Date) -> PlannedWorkoutDay?
}

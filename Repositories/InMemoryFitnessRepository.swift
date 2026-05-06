import Foundation

final class InMemoryFitnessRepository: FitnessRepository {
    private var userProfile: UserProfile
    private var exercises: [Exercise]
    private var workoutRecords: [WorkoutSessionRecord]
    private var generatedPlan: GeneratedPlan

    init(
        userProfile: UserProfile = MockUserProfile.current,
        exercises: [Exercise] = MockExercises.all,
        workoutRecords: [WorkoutSessionRecord] = MockWorkoutRecords.history,
        generatedPlan: GeneratedPlan = MockGeneratedPlan.nextWeekPlan
    ) {
        self.userProfile = userProfile
        self.exercises = exercises
        self.workoutRecords = workoutRecords
        self.generatedPlan = generatedPlan
    }

    func fetchUserProfile() -> UserProfile {
        userProfile
    }

    func fetchExercises() -> [Exercise] {
        exercises
    }

    func fetchWorkoutRecords() -> [WorkoutSessionRecord] {
        workoutRecords.sorted { $0.date > $1.date }
    }

    func fetchGeneratedPlan() -> GeneratedPlan {
        generatedPlan
    }

    func saveUserProfile(_ profile: UserProfile) {
        userProfile = profile
    }

    func saveWorkoutRecord(_ record: WorkoutSessionRecord) {
        workoutRecords.append(record)
    }

    func updateWorkoutRecord(_ record: WorkoutSessionRecord) {
        guard let index = workoutRecords.firstIndex(where: { $0.id == record.id }) else {
            saveWorkoutRecord(record)
            return
        }

        workoutRecords[index] = record
    }

    func plannedWorkout(on date: Date) -> PlannedWorkoutDay? {
        generatedPlan.days.first { $0.date.isSameFitPlannerDay(as: date) }
    }

    func nextPlannedWorkout(from date: Date) -> PlannedWorkoutDay? {
        generatedPlan.days
            .filter { !$0.isRestDay }
            .sorted { $0.date < $1.date }
            .first { $0.date.fitPlannerStartOfDay >= date.fitPlannerStartOfDay }
    }
}

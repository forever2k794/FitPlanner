import Foundation

final class JSONFitnessRepository: FitnessRepository {
    private let userProfile: UserProfile
    private let exercises: [Exercise]
    private let generatedPlan: GeneratedPlan
    private let workoutRecordStore: LocalJSONWorkoutRecordStore

    init(
        userProfile: UserProfile = MockUserProfile.current,
        exercises: [Exercise] = MockExercises.all,
        generatedPlan: GeneratedPlan = MockGeneratedPlan.nextWeekPlan,
        workoutRecordStore: LocalJSONWorkoutRecordStore = LocalJSONWorkoutRecordStore()
    ) {
        self.userProfile = userProfile
        self.exercises = exercises
        self.generatedPlan = generatedPlan
        self.workoutRecordStore = workoutRecordStore
    }

    func fetchUserProfile() -> UserProfile {
        userProfile
    }

    func fetchExercises() -> [Exercise] {
        exercises
    }

    func fetchWorkoutRecords() -> [WorkoutSessionRecord] {
        (MockWorkoutRecords.history + workoutRecordStore.loadRecords())
            .sorted { $0.date > $1.date }
    }

    func fetchGeneratedPlan() -> GeneratedPlan {
        generatedPlan
    }

    func saveWorkoutRecord(_ record: WorkoutSessionRecord) {
        var jsonRecords = workoutRecordStore.loadRecords()

        if let existingIndex = jsonRecords.firstIndex(where: { $0.id == record.id }) {
            jsonRecords[existingIndex] = record
        } else {
            jsonRecords.append(record)
        }

        workoutRecordStore.saveRecords(jsonRecords.sorted { $0.date > $1.date })
    }

    func updateWorkoutRecord(_ record: WorkoutSessionRecord) {
        saveWorkoutRecord(record)
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

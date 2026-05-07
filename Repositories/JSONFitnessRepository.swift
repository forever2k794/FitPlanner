import Foundation

final class JSONFitnessRepository: FitnessRepository {
    private let fallbackUserProfile: UserProfile
    private let exercises: [Exercise]
    private let generatedPlan: GeneratedPlan
    private let userProfileStore: LocalJSONUserProfileStore
    private let workoutRecordStore: LocalJSONWorkoutRecordStore

    init(
        userProfile: UserProfile = MockUserProfile.current,
        exercises: [Exercise] = MockExercises.all,
        generatedPlan: GeneratedPlan = MockGeneratedPlan.nextWeekPlan,
        userProfileStore: LocalJSONUserProfileStore = LocalJSONUserProfileStore(),
        workoutRecordStore: LocalJSONWorkoutRecordStore = LocalJSONWorkoutRecordStore()
    ) {
        self.fallbackUserProfile = userProfile
        self.exercises = exercises
        self.generatedPlan = generatedPlan
        self.userProfileStore = userProfileStore
        self.workoutRecordStore = workoutRecordStore
    }

    func fetchUserProfile() -> UserProfile {
        userProfileStore.loadProfile() ?? fallbackUserProfile
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

    func saveUserProfile(_ profile: UserProfile) {
        userProfileStore.saveProfile(profile)
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

    func deleteWorkoutRecord(id: UUID) {
        var jsonRecords = workoutRecordStore.loadRecords()
        jsonRecords.removeAll { $0.id == id }
        workoutRecordStore.saveRecords(jsonRecords.sorted { $0.date > $1.date })
    }

    func canDeleteWorkoutRecord(id: UUID) -> Bool {
        workoutRecordStore.loadRecords().contains { $0.id == id }
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

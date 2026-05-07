import Foundation

final class FitnessService {
    private let repository: FitnessRepository

    init(repository: FitnessRepository) {
        self.repository = repository
    }

    func userProfile() -> UserProfile {
        repository.fetchUserProfile()
    }

    func saveUserProfile(_ profile: UserProfile) {
        repository.saveUserProfile(profile)
    }

    func workoutRecords() -> [WorkoutSessionRecord] {
        repository.fetchWorkoutRecords()
    }

    func deleteWorkoutRecord(id: UUID) {
        repository.deleteWorkoutRecord(id: id)
    }

    func canDeleteWorkoutRecord(id: UUID) -> Bool {
        repository.canDeleteWorkoutRecord(id: id)
    }

    func workoutRecord(on date: Date = Date()) -> WorkoutSessionRecord? {
        repository.fetchWorkoutRecords().first {
            $0.date.isSameFitPlannerDay(as: date)
        }
    }

    func todayPlannedWorkout(referenceDate: Date = Date()) -> PlannedWorkoutDay? {
        repository.plannedWorkout(on: referenceDate)
    }

    func hasCompletedWorkout(on date: Date = Date()) -> Bool {
        repository.fetchWorkoutRecords().contains {
            $0.date.isSameFitPlannerDay(as: date) && $0.isCompleted
        }
    }

    @discardableResult
    func completeWorkout(for plannedDay: PlannedWorkoutDay, date: Date = Date()) -> WorkoutSessionRecord {
        let logs = plannedDay.plannedExercises.map { plannedExercise in
            let sets = (0..<plannedExercise.targetSets).map { index in
                SetLog(
                    setNumber: index + 1,
                    weightInKilograms: plannedExercise.suggestedWeightInKilograms,
                    reps: plannedExercise.targetReps,
                    rpe: plannedExercise.targetRPE,
                    rir: plannedExercise.targetRIR,
                    isCompleted: true
                )
            }

            return ExerciseLog(
                exercise: plannedExercise.exercise,
                sets: sets
            )
        }

        return saveWorkoutSession(
            title: plannedDay.title,
            date: date,
            exerciseLogs: logs,
            note: "由今日 mock 課表完成。"
        )
    }

    @discardableResult
    func saveWorkoutSession(
        title: String,
        date: Date = Date(),
        exerciseLogs: [ExerciseLog],
        note: String = "由今日訓練編輯流程儲存。"
    ) -> WorkoutSessionRecord {
        let record = WorkoutSessionRecord(
            title: title,
            date: date,
            exerciseLogs: exerciseLogs,
            isCompleted: true,
            note: note
        )

        repository.saveWorkoutRecord(record)
        return record
    }
}

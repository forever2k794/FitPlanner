import Foundation

final class FitnessService {
    private let repository: FitnessRepository

    init(repository: FitnessRepository) {
        self.repository = repository
    }

    func userProfile() -> UserProfile {
        repository.fetchUserProfile()
    }

    func workoutRecords() -> [WorkoutSessionRecord] {
        repository.fetchWorkoutRecords()
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
            let sets = (1...plannedExercise.targetSets).map { setNumber in
                SetLog(
                    setNumber: setNumber,
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

        let record = WorkoutSessionRecord(
            title: plannedDay.title,
            date: date,
            exerciseLogs: logs,
            isCompleted: true,
            note: "由今日 mock 課表完成。"
        )

        repository.saveWorkoutRecord(record)
        return record
    }
}

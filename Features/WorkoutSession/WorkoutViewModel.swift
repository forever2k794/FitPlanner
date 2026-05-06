import Combine
import Foundation

@MainActor
final class WorkoutViewModel: ObservableObject {
    @Published private(set) var plannedWorkoutDay: PlannedWorkoutDay?
    @Published private(set) var exerciseLogDrafts: [ExerciseLog]
    @Published private(set) var hasCompletedToday: Bool
    @Published var completionMessage: String?

    private let fitnessService: FitnessService
    private let planGenerationService: PlanGenerationService

    init(
        fitnessService: FitnessService,
        planGenerationService: PlanGenerationService
    ) {
        self.fitnessService = fitnessService
        self.planGenerationService = planGenerationService
        self.plannedWorkoutDay = nil
        self.exerciseLogDrafts = []
        self.hasCompletedToday = false
        refresh(rebuildDraft: true)
    }

    var canSaveWorkoutSession: Bool {
        plannedWorkoutDay?.isRestDay == false && !hasCompletedToday && !exerciseLogDrafts.isEmpty
    }

    func refresh(rebuildDraft: Bool = false) {
        plannedWorkoutDay = planGenerationService.generateNextWorkout()
        hasCompletedToday = fitnessService.hasCompletedWorkout()

        if rebuildDraft || exerciseLogDrafts.isEmpty {
            exerciseLogDrafts = makeExerciseLogDrafts(from: plannedWorkoutDay)
        }
    }

    func plannedExercise(for exerciseID: UUID) -> PlannedExercise? {
        plannedWorkoutDay?.plannedExercises.first { $0.exercise.id == exerciseID }
    }

    func addSet(to exerciseLogID: UUID) {
        guard let exerciseLogIndex = exerciseLogDrafts.firstIndex(where: { $0.id == exerciseLogID }) else {
            return
        }

        let existingSets = exerciseLogDrafts[exerciseLogIndex].sets
        let previousSet = existingSets.last
        let nextSet = SetLog(
            setNumber: existingSets.count + 1,
            weightInKilograms: previousSet?.weightInKilograms ?? plannedExercise(for: exerciseLogDrafts[exerciseLogIndex].exercise.id)?.suggestedWeightInKilograms ?? 0,
            reps: previousSet?.reps ?? plannedExercise(for: exerciseLogDrafts[exerciseLogIndex].exercise.id)?.targetReps ?? 8,
            rpe: previousSet?.rpe ?? plannedExercise(for: exerciseLogDrafts[exerciseLogIndex].exercise.id)?.targetRPE,
            rir: previousSet?.rir ?? plannedExercise(for: exerciseLogDrafts[exerciseLogIndex].exercise.id)?.targetRIR,
            isCompleted: false
        )

        exerciseLogDrafts[exerciseLogIndex].sets.append(nextSet)
        normalizeSetNumbers(for: exerciseLogIndex)
        completionMessage = nil
    }

    func deleteSet(_ setID: UUID, from exerciseLogID: UUID) {
        guard let exerciseLogIndex = exerciseLogDrafts.firstIndex(where: { $0.id == exerciseLogID }) else {
            return
        }

        exerciseLogDrafts[exerciseLogIndex].sets.removeAll { $0.id == setID }
        normalizeSetNumbers(for: exerciseLogIndex)
        completionMessage = nil
    }

    func updateSet(_ updatedSet: SetLog, in exerciseLogID: UUID) {
        guard
            let exerciseLogIndex = exerciseLogDrafts.firstIndex(where: { $0.id == exerciseLogID }),
            let setIndex = exerciseLogDrafts[exerciseLogIndex].sets.firstIndex(where: { $0.id == updatedSet.id })
        else {
            return
        }

        exerciseLogDrafts[exerciseLogIndex].sets[setIndex] = updatedSet
        completionMessage = nil
    }

    func completeTodayWorkout() {
        guard let plannedWorkoutDay, !plannedWorkoutDay.isRestDay else {
            completionMessage = "今天沒有可完成的訓練課表。"
            return
        }

        guard !hasCompletedToday else {
            completionMessage = "今日訓練已完成。"
            return
        }

        let record = fitnessService.completeWorkout(for: plannedWorkoutDay)
        hasCompletedToday = true
        completionMessage = "已新增「\(record.title)」訓練紀錄。"
    }

    func saveWorkoutSession() {
        guard let plannedWorkoutDay, !plannedWorkoutDay.isRestDay else {
            completionMessage = "今天沒有可儲存的訓練課表。"
            return
        }

        guard !hasCompletedToday else {
            completionMessage = "今日訓練已經儲存。"
            return
        }

        guard !exerciseLogDrafts.isEmpty else {
            completionMessage = "請先建立至少一個動作紀錄。"
            return
        }

        let record = fitnessService.saveWorkoutSession(
            title: plannedWorkoutDay.title,
            exerciseLogs: exerciseLogDrafts
        )
        refresh(rebuildDraft: true)
        completionMessage = "已儲存「\(record.title)」訓練紀錄。"
    }

    private func makeExerciseLogDrafts(from plannedWorkoutDay: PlannedWorkoutDay?) -> [ExerciseLog] {
        guard let plannedWorkoutDay, !plannedWorkoutDay.isRestDay else {
            return []
        }

        return plannedWorkoutDay.plannedExercises.map { plannedExercise in
            let sets = (0..<plannedExercise.targetSets).map { index in
                SetLog(
                    setNumber: index + 1,
                    weightInKilograms: plannedExercise.suggestedWeightInKilograms,
                    reps: plannedExercise.targetReps,
                    rpe: plannedExercise.targetRPE,
                    rir: plannedExercise.targetRIR,
                    isCompleted: false
                )
            }

            return ExerciseLog(
                exercise: plannedExercise.exercise,
                sets: sets
            )
        }
    }

    private func normalizeSetNumbers(for exerciseLogIndex: Int) {
        exerciseLogDrafts[exerciseLogIndex].sets = exerciseLogDrafts[exerciseLogIndex].sets.enumerated().map { index, setLog in
            SetLog(
                id: setLog.id,
                setNumber: index + 1,
                weightInKilograms: setLog.weightInKilograms,
                reps: setLog.reps,
                rpe: setLog.rpe,
                rir: setLog.rir,
                isCompleted: setLog.isCompleted
            )
        }
    }
}

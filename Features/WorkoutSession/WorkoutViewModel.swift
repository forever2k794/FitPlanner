import Combine
import Foundation

enum WorkoutFeedbackStyle {
    case success
    case warning
    case info
}

@MainActor
final class WorkoutViewModel: ObservableObject {
    @Published private(set) var plannedWorkoutDay: PlannedWorkoutDay?
    @Published private(set) var planGenerationExplanation: PlanGenerationExplanation?
    @Published private(set) var exerciseLogDrafts: [ExerciseLog]
    @Published private(set) var hasCompletedToday: Bool
    @Published var completionMessage: String?
    @Published private(set) var completionMessageStyle: WorkoutFeedbackStyle
    @Published private(set) var selectedFocusType: WorkoutFocusType
    @Published private(set) var selectedTrainingStyle: TrainingStyle
    @Published private(set) var selectedEquipmentTypes: Set<EquipmentType>
    @Published private(set) var availableExercises: [Exercise]

    private let fitnessService: FitnessService
    private let planGenerationService: PlanGenerationService

    let availableFocusTypes: [WorkoutFocusType] = WorkoutFocusType.allCases
    let availableTrainingStyles: [TrainingStyle] = TrainingStyle.allCases
    let availableEquipmentTypes: [EquipmentType] = EquipmentType.allCases

    init(
        fitnessService: FitnessService,
        planGenerationService: PlanGenerationService
    ) {
        self.fitnessService = fitnessService
        self.planGenerationService = planGenerationService
        self.plannedWorkoutDay = nil
        self.planGenerationExplanation = nil
        self.exerciseLogDrafts = []
        self.hasCompletedToday = false
        self.completionMessageStyle = .info
        self.selectedFocusType = .recommended
        self.selectedTrainingStyle = .hypertrophy
        self.selectedEquipmentTypes = Set(EquipmentType.allCases)
        self.availableExercises = fitnessService.exercises().sorted { $0.name < $1.name }
        refresh(rebuildDraft: true)
    }

    var canSaveWorkoutSession: Bool {
        !hasCompletedToday && !exerciseLogDrafts.isEmpty
    }

    func refresh(rebuildDraft: Bool = false) {
        availableExercises = fitnessService.exercises().sorted { $0.name < $1.name }
        let result = planGenerationService.generateNextWorkoutWithExplanation(
            preference: currentPreference
        )
        plannedWorkoutDay = result.plannedWorkoutDay
        planGenerationExplanation = result.explanation
        hasCompletedToday = fitnessService.hasCompletedWorkout()

        if rebuildDraft || exerciseLogDrafts.isEmpty {
            exerciseLogDrafts = makeExerciseLogDrafts(from: plannedWorkoutDay)
        }
    }

    func plannedExercise(for exerciseID: UUID) -> PlannedExercise? {
        plannedWorkoutDay?.plannedExercises.first { $0.exercise.id == exerciseID }
    }

    func selectFocusType(_ focusType: WorkoutFocusType) {
        selectedFocusType = focusType
        completionMessage = nil
    }

    func selectTrainingStyle(_ trainingStyle: TrainingStyle) {
        selectedTrainingStyle = trainingStyle
        completionMessage = nil
    }

    func toggleEquipmentType(_ equipmentType: EquipmentType) {
        if selectedEquipmentTypes.contains(equipmentType) {
            selectedEquipmentTypes.remove(equipmentType)
        } else {
            selectedEquipmentTypes.insert(equipmentType)
        }

        completionMessage = nil
    }

    func isEquipmentSelected(_ equipmentType: EquipmentType) -> Bool {
        selectedEquipmentTypes.contains(equipmentType)
    }

    func regenerateWorkout() {
        refresh(rebuildDraft: true)
        completionMessage = "已依照目前偏好重新產生課表。"
        completionMessageStyle = .success
    }

    func addExercise(_ exercise: Exercise) {
        guard !exerciseLogDrafts.contains(where: { $0.exercise.name == exercise.name }) else {
            completionMessage = "「\(exercise.name)」已在今日訓練中。"
            completionMessageStyle = .warning
            return
        }

        exerciseLogDrafts.append(makeExerciseLogDraft(for: exercise))
        completionMessage = "已加入「\(exercise.name)」。"
        completionMessageStyle = .success
    }

    func removeExerciseLog(_ exerciseLogID: UUID) {
        guard let exerciseLog = exerciseLogDrafts.first(where: { $0.id == exerciseLogID }) else {
            return
        }

        exerciseLogDrafts.removeAll { $0.id == exerciseLogID }
        completionMessage = "已移除「\(exerciseLog.exercise.name)」。"
        completionMessageStyle = .info
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
        completionMessageStyle = .info
    }

    func deleteSet(_ setID: UUID, from exerciseLogID: UUID) {
        guard let exerciseLogIndex = exerciseLogDrafts.firstIndex(where: { $0.id == exerciseLogID }) else {
            return
        }

        exerciseLogDrafts[exerciseLogIndex].sets.removeAll { $0.id == setID }
        normalizeSetNumbers(for: exerciseLogIndex)
        completionMessage = nil
        completionMessageStyle = .info
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
        completionMessageStyle = .info
    }

    func completeTodayWorkout() {
        guard let plannedWorkoutDay, !plannedWorkoutDay.isRestDay else {
            completionMessage = "今天沒有可完成的訓練課表。"
            completionMessageStyle = .warning
            return
        }

        guard !hasCompletedToday else {
            completionMessage = "本次訓練已完成。"
            completionMessageStyle = .info
            return
        }

        let record = fitnessService.completeWorkout(for: plannedWorkoutDay)
        hasCompletedToday = true
        completionMessage = "已新增「\(record.title)」訓練紀錄。"
        completionMessageStyle = .success
    }

    func saveWorkoutSession() {
        guard !hasCompletedToday else {
            completionMessage = "本次訓練已經儲存。"
            completionMessageStyle = .info
            return
        }

        guard !exerciseLogDrafts.isEmpty else {
            completionMessage = "請先建立至少一個動作紀錄。"
            completionMessageStyle = .warning
            return
        }

        let record = fitnessService.saveWorkoutSession(
            title: plannedWorkoutDay?.title ?? selectedFocusType.displayName,
            exerciseLogs: exerciseLogDrafts
        )
        refresh(rebuildDraft: true)
        completionMessage = "已儲存「\(record.title)」訓練紀錄。"
        completionMessageStyle = .success
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

    private var currentPreference: WorkoutGenerationPreference {
        WorkoutGenerationPreference(
            focusType: selectedFocusType,
            availableEquipment: Array(selectedEquipmentTypes),
            trainingStyle: selectedTrainingStyle
        )
    }

    private func makeExerciseLogDraft(for exercise: Exercise) -> ExerciseLog {
        let latestLog = latestExerciseLog(for: exercise)
        let templateSet = latestLog?.sets.last(where: \.isCompleted) ?? latestLog?.sets.last
        let setCount = max(exercise.defaultSets, 1)
        let reps = templateSet?.reps ?? repsForSelectedStyle(exercise.defaultReps)
        let weight = templateSet?.weightInKilograms ?? defaultWeight(for: exercise)
        let rpe = templateSet?.rpe ?? defaultRPEForSelectedStyle()
        let rir = templateSet?.rir ?? defaultRIRForSelectedStyle()
        let sets = (0..<setCount).map { index in
            SetLog(
                setNumber: index + 1,
                weightInKilograms: weight,
                reps: reps,
                rpe: rpe,
                rir: rir,
                isCompleted: false
            )
        }

        return ExerciseLog(
            exercise: exercise,
            sets: sets
        )
    }

    private func latestExerciseLog(for exercise: Exercise) -> ExerciseLog? {
        fitnessService.workoutRecords()
            .sorted { $0.date > $1.date }
            .flatMap(\.exerciseLogs)
            .first { $0.exercise.name == exercise.name }
    }

    private func repsForSelectedStyle(_ defaultReps: Int) -> Int {
        switch selectedTrainingStyle {
        case .strength:
            return min(max(defaultReps, 3), 6)
        case .hypertrophy, .custom:
            return min(max(defaultReps, 8), 12)
        case .endurance:
            return min(max(defaultReps, 12), 20)
        case .recovery:
            return min(max(defaultReps, 10), 15)
        }
    }

    private func defaultWeight(for exercise: Exercise) -> Double {
        let weight = ExerciseProgressionRule.defaultWeight(for: exercise.name)

        switch selectedTrainingStyle {
        case .recovery:
            return max((weight * 0.6 * 2).rounded() / 2, 0)
        case .endurance:
            return max((weight * 0.8 * 2).rounded() / 2, 0)
        default:
            return weight
        }
    }

    private func defaultRPEForSelectedStyle() -> Double {
        selectedTrainingStyle == .recovery ? 6.5 : 8
    }

    private func defaultRIRForSelectedStyle() -> Int {
        selectedTrainingStyle == .recovery ? 4 : 2
    }
}

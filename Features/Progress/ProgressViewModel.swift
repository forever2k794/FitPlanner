import Combine
import Foundation

@MainActor
final class ProgressViewModel: ObservableObject {
    @Published private(set) var summary: ProgressSummary
    @Published private(set) var weeklyMetrics: [WeeklyProgressMetric]
    @Published private(set) var exercisePRs: [ExercisePRMetric]
    @Published private(set) var muscleGroupFrequencies: [MuscleGroupFrequencyMetric]
    @Published private(set) var focusDistributionMetrics: [TrainingFocusDistributionMetric]
    @Published private(set) var availableTrendExerciseNames: [String]
    @Published private(set) var selectedTrendExerciseName: String?
    @Published private(set) var exerciseTrendMetrics: [ExerciseTrendMetric]
    @Published private(set) var currentWeekWorkoutCount: Int
    @Published private(set) var weeklyTargetTrainingDays: Int
    @Published private(set) var trainingRecommendations: [String]

    private let progressSummaryService: ProgressSummaryService
    private let fitnessService: FitnessService

    init(
        progressSummaryService: ProgressSummaryService,
        fitnessService: FitnessService
    ) {
        self.progressSummaryService = progressSummaryService
        self.fitnessService = fitnessService
        self.summary = ProgressSummary(
            totalWorkoutCount: 0,
            weeklyTotalVolume: 0,
            latestWorkoutDate: nil,
            mostTrainedMuscleGroup: "尚無資料"
        )
        self.weeklyMetrics = []
        self.exercisePRs = []
        self.muscleGroupFrequencies = []
        self.focusDistributionMetrics = []
        self.availableTrendExerciseNames = []
        self.selectedTrendExerciseName = nil
        self.exerciseTrendMetrics = []
        self.currentWeekWorkoutCount = 0
        self.weeklyTargetTrainingDays = 1
        self.trainingRecommendations = []
        refresh()
    }

    func refresh() {
        let records = fitnessService.workoutRecords()
        let profile = fitnessService.userProfile()
        summary = progressSummaryService.progressSummary()
        weeklyMetrics = progressSummaryService.weeklyProgressMetrics(from: records)
        exercisePRs = progressSummaryService.exercisePRMetrics(from: records)
        muscleGroupFrequencies = progressSummaryService.muscleGroupFrequencyMetrics(from: records)
        focusDistributionMetrics = progressSummaryService.focusDistributionMetrics(from: records)
        availableTrendExerciseNames = progressSummaryService.availableTrendExerciseNames(from: records)
        weeklyTargetTrainingDays = max(profile.weeklyTargetTrainingDays, 1)
        currentWeekWorkoutCount = records.filter {
            $0.date.isInCurrentFitPlannerWeek() && $0.isCompleted
        }.count
        trainingRecommendations = progressSummaryService.trainingRecommendations(from: records, profile: profile)

        if let selectedTrendExerciseName, availableTrendExerciseNames.contains(selectedTrendExerciseName) {
            exerciseTrendMetrics = progressSummaryService.exerciseTrendMetrics(
                from: records,
                exerciseName: selectedTrendExerciseName
            )
        } else {
            selectedTrendExerciseName = availableTrendExerciseNames.first
            exerciseTrendMetrics = selectedTrendExerciseName.map {
                progressSummaryService.exerciseTrendMetrics(from: records, exerciseName: $0)
            } ?? []
        }
    }

    func selectTrendExercise(_ exerciseName: String) {
        selectedTrendExerciseName = exerciseName
        exerciseTrendMetrics = progressSummaryService.exerciseTrendMetrics(
            from: fitnessService.workoutRecords(),
            exerciseName: exerciseName
        )
    }

    var weeklyTargetProgress: Double {
        min(Double(currentWeekWorkoutCount) / Double(max(weeklyTargetTrainingDays, 1)), 1)
    }
}

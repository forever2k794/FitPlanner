import Combine
import Foundation

@MainActor
final class ProgressViewModel: ObservableObject {
    @Published private(set) var summary: ProgressSummary
    @Published private(set) var weeklyMetrics: [WeeklyProgressMetric]
    @Published private(set) var exercisePRs: [ExercisePRMetric]
    @Published private(set) var muscleGroupFrequencies: [MuscleGroupFrequencyMetric]

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
        refresh()
    }

    func refresh() {
        let records = fitnessService.workoutRecords()
        summary = progressSummaryService.progressSummary()
        weeklyMetrics = progressSummaryService.weeklyProgressMetrics(from: records)
        exercisePRs = progressSummaryService.exercisePRMetrics(from: records)
        muscleGroupFrequencies = progressSummaryService.muscleGroupFrequencyMetrics(from: records)
    }
}

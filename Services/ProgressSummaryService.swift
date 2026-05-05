import Foundation

struct DashboardSummary {
    var weeklyCompletionRate: Double
    var weeklyTotalVolume: Double
    var nextWorkout: PlannedWorkoutDay?
    var latestWorkout: WorkoutSessionRecord?
}

struct ProgressSummary {
    var totalWorkoutCount: Int
    var weeklyTotalVolume: Double
    var latestWorkoutDate: Date?
    var mostTrainedMuscleGroup: String
}

final class ProgressSummaryService {
    private let repository: FitnessRepository

    init(repository: FitnessRepository) {
        self.repository = repository
    }

    func dashboardSummary(referenceDate: Date = Date()) -> DashboardSummary {
        let profile = repository.fetchUserProfile()
        let records = repository.fetchWorkoutRecords()
        let currentWeekRecords = records.filter { $0.date.isInCurrentFitPlannerWeek(referenceDate: referenceDate) }
        let completedThisWeek = currentWeekRecords.filter(\.isCompleted).count
        let targetDays = max(profile.weeklyTargetTrainingDays, 1)
        let completionRate = min(Double(completedThisWeek) / Double(targetDays), 1)

        return DashboardSummary(
            weeklyCompletionRate: completionRate,
            weeklyTotalVolume: currentWeekRecords.reduce(0) { $0 + $1.totalVolume },
            nextWorkout: repository.nextPlannedWorkout(from: referenceDate),
            latestWorkout: records.first
        )
    }

    func progressSummary(referenceDate: Date = Date()) -> ProgressSummary {
        let records = repository.fetchWorkoutRecords()
        let currentWeekRecords = records.filter { $0.date.isInCurrentFitPlannerWeek(referenceDate: referenceDate) }
        let muscleGroups = records.flatMap { record in
            record.exerciseLogs.map(\.exercise.primaryMuscleGroup)
        }
        let mostTrainedMuscleGroup = muscleGroups
            .reduce(into: [String: Int]()) { counts, muscleGroup in
                counts[muscleGroup, default: 0] += 1
            }
            .max { $0.value < $1.value }?
            .key ?? "尚無資料"

        return ProgressSummary(
            totalWorkoutCount: records.count,
            weeklyTotalVolume: currentWeekRecords.reduce(0) { $0 + $1.totalVolume },
            latestWorkoutDate: records.first?.date,
            mostTrainedMuscleGroup: mostTrainedMuscleGroup
        )
    }
}

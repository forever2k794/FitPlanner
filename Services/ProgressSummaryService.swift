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

    func weeklyProgressMetrics(
        from records: [WorkoutSessionRecord],
        weeks: Int = 8,
        referenceDate: Date = Date()
    ) -> [WeeklyProgressMetric] {
        let weekCount = max(weeks, 1)
        let currentWeekStart = referenceDate.fitPlannerStartOfWeek

        return (0..<weekCount).reversed().map { offset in
            let weekStart = Calendar.fitPlanner.date(
                byAdding: .day,
                value: -7 * offset,
                to: currentWeekStart
            ) ?? currentWeekStart
            let nextWeekStart = Calendar.fitPlanner.date(
                byAdding: .day,
                value: 7,
                to: weekStart
            ) ?? weekStart
            let weekRecords = records.filter { record in
                record.date >= weekStart && record.date < nextWeekStart
            }

            return WeeklyProgressMetric(
                weekStartDate: weekStart,
                label: weekLabel(for: weekStart),
                totalVolume: weekRecords.reduce(0) { $0 + $1.totalVolume },
                workoutCount: weekRecords.filter(\.isCompleted).count
            )
        }
    }

    func exercisePRMetrics(
        from records: [WorkoutSessionRecord],
        exerciseNames: [String] = ["深蹲", "槓鈴臥推", "臥推", "羅馬尼亞硬舉", "硬舉", "肩推", "槓鈴划船", "划船"]
    ) -> [ExercisePRMetric] {
        var personalRecords: [String: ExercisePRMetric] = [:]

        for record in records {
            for exerciseLog in record.exerciseLogs where exerciseNames.contains(exerciseLog.exercise.name) {
                for set in exerciseLog.sets where set.isCompleted && set.weightInKilograms > 0 {
                    let currentPR = personalRecords[exerciseLog.exercise.name]

                    guard shouldReplacePR(
                        weight: set.weightInKilograms,
                        reps: set.reps,
                        date: record.date,
                        currentPR: currentPR
                    ) else {
                        continue
                    }

                    personalRecords[exerciseLog.exercise.name] = ExercisePRMetric(
                        exerciseName: exerciseLog.exercise.name,
                        weightInKilograms: set.weightInKilograms,
                        reps: set.reps,
                        date: record.date
                    )
                }
            }
        }

        let exerciseOrder = Dictionary(
            uniqueKeysWithValues: exerciseNames.enumerated().map { index, name in
                (name, index)
            }
        )

        return personalRecords.values.sorted { lhs, rhs in
            let lhsOrder = exerciseOrder[lhs.exerciseName] ?? Int.max
            let rhsOrder = exerciseOrder[rhs.exerciseName] ?? Int.max

            if lhsOrder != rhsOrder {
                return lhsOrder < rhsOrder
            }

            return lhs.weightInKilograms > rhs.weightInKilograms
        }
    }

    func muscleGroupFrequencyMetrics(
        from records: [WorkoutSessionRecord],
        limit: Int = 6
    ) -> [MuscleGroupFrequencyMetric] {
        let counts = records
            .flatMap { record in
                record.exerciseLogs.map(\.exercise.primaryMuscleGroup)
            }
            .reduce(into: [String: Int]()) { result, muscleGroup in
                result[muscleGroup, default: 0] += 1
            }

        return counts
            .map { muscleGroup, count in
                MuscleGroupFrequencyMetric(
                    muscleGroup: muscleGroup,
                    trainingCount: count
                )
            }
            .sorted { lhs, rhs in
                if lhs.trainingCount != rhs.trainingCount {
                    return lhs.trainingCount > rhs.trainingCount
                }

                return lhs.muscleGroup < rhs.muscleGroup
            }
            .prefix(limit)
            .map { $0 }
    }

    private func shouldReplacePR(
        weight: Double,
        reps: Int,
        date: Date,
        currentPR: ExercisePRMetric?
    ) -> Bool {
        guard let currentPR else {
            return true
        }

        if weight != currentPR.weightInKilograms {
            return weight > currentPR.weightInKilograms
        }

        if reps != currentPR.reps {
            return reps > currentPR.reps
        }

        return date > currentPR.date
    }

    private func weekLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hant_TW")
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

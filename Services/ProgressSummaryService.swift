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

    func exerciseTrendMetrics(
        from records: [WorkoutSessionRecord],
        exerciseName: String,
        limit: Int = 8
    ) -> [ExerciseTrendMetric] {
        records
            .sorted { $0.date < $1.date }
            .compactMap { record in
                let matchingSets = record.exerciseLogs
                    .filter { $0.exercise.name == exerciseName }
                    .flatMap(\.sets)
                    .filter(\.isCompleted)

                guard !matchingSets.isEmpty else {
                    return nil
                }

                let maxWeight = matchingSets.map(\.weightInKilograms).max() ?? 0
                let maxReps = matchingSets.map(\.reps).max() ?? 0

                return ExerciseTrendMetric(
                    id: record.id,
                    date: record.date,
                    label: shortDateLabel(for: record.date),
                    maxWeightInKilograms: maxWeight,
                    maxReps: maxReps
                )
            }
            .suffix(limit)
            .map { $0 }
    }

    func availableTrendExerciseNames(from records: [WorkoutSessionRecord]) -> [String] {
        let counts = records
            .flatMap(\.exerciseLogs)
            .reduce(into: [String: Int]()) { result, exerciseLog in
                result[exerciseLog.exercise.name, default: 0] += 1
            }

        return counts
            .sorted { lhs, rhs in
                if lhs.value != rhs.value {
                    return lhs.value > rhs.value
                }

                return lhs.key < rhs.key
            }
            .map(\.key)
    }

    func focusDistributionMetrics(from records: [WorkoutSessionRecord]) -> [TrainingFocusDistributionMetric] {
        var counts: [String: Int] = [
            "推": 0,
            "拉": 0,
            "腿": 0,
            "核心": 0
        ]

        for exerciseLog in records.flatMap(\.exerciseLogs) {
            for focusName in distributionFocusNames(for: exerciseLog.exercise) {
                counts[focusName, default: 0] += 1
            }
        }

        return ["推", "拉", "腿", "核心"].compactMap { focusName in
            guard let count = counts[focusName], count > 0 else {
                return nil
            }

            return TrainingFocusDistributionMetric(
                focusName: focusName,
                trainingCount: count
            )
        }
    }

    func trainingRecommendations(
        from records: [WorkoutSessionRecord],
        profile: UserProfile,
        referenceDate: Date = Date()
    ) -> [String] {
        guard !records.isEmpty else {
            return ["目前紀錄較少，新手可先用全身訓練建立穩定頻率。"]
        }

        var recommendations: [String] = []
        let currentWeekCount = records
            .filter { $0.date.isInCurrentFitPlannerWeek(referenceDate: referenceDate) && $0.isCompleted }
            .count

        if currentWeekCount < profile.weeklyTargetTrainingDays {
            recommendations.append("本週已完成 \(currentWeekCount) 次，尚未達到每週 \(profile.weeklyTargetTrainingDays) 次目標。")
        }

        let distribution = Dictionary(
            uniqueKeysWithValues: focusDistributionMetrics(from: records).map { ($0.focusName, $0.trainingCount) }
        )
        let pushCount = distribution["推"] ?? 0
        let pullCount = distribution["拉"] ?? 0
        let legsCount = distribution["腿"] ?? 0

        if legsCount < max(pushCount, pullCount) / 2 {
            recommendations.append("最近腿部訓練相對較少，可以安排一次腿部或全身訓練。")
        }

        if pushCount > pullCount + 2 {
            recommendations.append("最近推類動作較多，建議加入拉類訓練平衡肩背。")
        } else if pullCount > pushCount + 2 {
            recommendations.append("最近拉類動作較多，下次可安排推類或全身訓練。")
        }

        if recommendations.isEmpty {
            recommendations.append("目前訓練分布看起來穩定，可以依今日狀態在課表頁調整強度。")
        }

        return recommendations
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

    private func shortDateLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hant_TW")
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }

    private func distributionFocusNames(for exercise: Exercise) -> [String] {
        var focusNames: Set<String> = []

        if exercise.supportedFocusTypes.contains(.push) ||
            exercise.primaryMuscleGroups.contains(.chest) ||
            exercise.primaryMuscleGroups.contains(.shoulders) ||
            exercise.primaryMuscleGroups.contains(.triceps) {
            focusNames.insert("推")
        }

        if exercise.supportedFocusTypes.contains(.pull) ||
            exercise.primaryMuscleGroups.contains(.back) ||
            exercise.primaryMuscleGroups.contains(.biceps) {
            focusNames.insert("拉")
        }

        if exercise.supportedFocusTypes.contains(.legs) ||
            exercise.primaryMuscleGroups.contains(.quads) ||
            exercise.primaryMuscleGroups.contains(.hamstrings) ||
            exercise.primaryMuscleGroups.contains(.glutes) ||
            exercise.primaryMuscleGroups.contains(.calves) {
            focusNames.insert("腿")
        }

        if exercise.supportedFocusTypes.contains(.core) ||
            exercise.primaryMuscleGroups.contains(.core) {
            focusNames.insert("核心")
        }

        return Array(focusNames)
    }
}

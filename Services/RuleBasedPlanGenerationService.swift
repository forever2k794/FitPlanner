import Foundation

final class RuleBasedPlanGenerationService {
    func generateNextWorkout(
        profile: UserProfile,
        workoutRecords: [WorkoutSessionRecord],
        exercises: [Exercise]
    ) -> PlannedWorkoutDay {
        generateNextWorkoutWithExplanation(
            profile: profile,
            workoutRecords: workoutRecords,
            exercises: exercises
        ).plannedWorkoutDay
    }

    func generateNextWorkoutWithExplanation(
        profile: UserProfile,
        workoutRecords: [WorkoutSessionRecord],
        exercises: [Exercise]
    ) -> (plannedWorkoutDay: PlannedWorkoutDay, explanation: PlanGenerationExplanation) {
        let sortedRecords = workoutRecords.sorted { $0.date > $1.date }
        let splitType = nextSplitType(
            weeklyTargetTrainingDays: profile.weeklyTargetTrainingDays,
            latestRecord: sortedRecords.first
        )
        let selectedExercises = exerciseNames(for: splitType).compactMap { exercise(named: $0, in: exercises) }

        let exerciseResults = selectedExercises.map { exercise in
            plannedExerciseWithExplanation(
                for: exercise,
                previousLog: latestExerciseLog(for: exercise, in: sortedRecords)
            )
        }

        let plannedWorkoutDay = PlannedWorkoutDay(
            date: Date().addingFitPlannerDays(1),
            title: splitType.displayName,
            focus: focusName(for: splitType),
            plannedExercises: exerciseResults.map { $0.plannedExercise }
        )
        let explanation = PlanGenerationExplanation(
            summary: summaryText(for: splitType, profile: profile, latestRecord: sortedRecords.first),
            splitReason: splitReasonText(
                for: splitType,
                weeklyTargetTrainingDays: profile.weeklyTargetTrainingDays,
                latestRecord: sortedRecords.first
            ),
            historyReference: historyReferenceText(from: sortedRecords),
            exerciseReasons: exerciseResults.map { $0.explanation }
        )

        return (plannedWorkoutDay, explanation)
    }

    private func nextSplitType(
        weeklyTargetTrainingDays: Int,
        latestRecord: WorkoutSessionRecord?
    ) -> TrainingSplitType {
        guard let latestRecord else {
            return .fullBody
        }

        let latestSplit = splitType(from: latestRecord)

        switch weeklyTargetTrainingDays {
        case ...2:
            return latestSplit == .fullBodyA ? .fullBodyB : .fullBodyA
        case 3:
            switch latestSplit {
            case .fullBodyA:
                return .fullBodyB
            case .fullBodyB:
                return .fullBodyC
            default:
                return .fullBodyA
            }
        case 4...5:
            switch latestSplit {
            case .upperPush:
                return .upperPull
            case .upperPull:
                return .lowerBody
            case .lowerBody:
                return .fullBodyVolume
            case .fullBodyVolume:
                return .upperPush
            default:
                return .upperPush
            }
        default:
            switch latestSplit {
            case .push:
                return .pull
            case .pull:
                return .legs
            case .legs:
                return .push
            default:
                return .push
            }
        }
    }

    private func splitType(from record: WorkoutSessionRecord) -> TrainingSplitType {
        let title = record.title

        if title.contains("上肢推") {
            return .upperPush
        }

        if title.contains("上肢拉") {
            return .upperPull
        }

        if title.contains("下肢") || title.contains("腿") {
            return .lowerBody
        }

        if title.contains("全身容量") {
            return .fullBodyVolume
        }

        if title.contains("全身 A") {
            return .fullBodyA
        }

        if title.contains("全身 B") {
            return .fullBodyB
        }

        if title.contains("全身 C") {
            return .fullBodyC
        }

        if title.contains("推") {
            return .push
        }

        if title.contains("拉") {
            return .pull
        }

        return inferSplitType(from: record)
    }

    private func inferSplitType(from record: WorkoutSessionRecord) -> TrainingSplitType {
        let muscleGroups = Set(record.exerciseLogs.map(\.exercise.primaryMuscleGroup))

        if muscleGroups.contains("胸部") || muscleGroups.contains("肩部") {
            return .upperPush
        }

        if muscleGroups.contains("背部") {
            return .upperPull
        }

        if muscleGroups.contains("腿部") || muscleGroups.contains("腿後側") {
            return .lowerBody
        }

        return .fullBody
    }

    private func exerciseNames(for splitType: TrainingSplitType) -> [String] {
        switch splitType {
        case .fullBody, .fullBodyA:
            return ["深蹲", "臥推", "划船", "腹部訓練"]
        case .fullBodyB:
            return ["硬舉", "肩推", "滑輪下拉", "腿彎舉"]
        case .fullBodyC:
            return ["腿推", "臥推", "划船", "側平舉"]
        case .upperPush, .push:
            return ["臥推", "肩推", "側平舉", "腹部訓練"]
        case .upperPull, .pull:
            return ["硬舉", "划船", "滑輪下拉", "腹部訓練"]
        case .lowerBody, .legs:
            return ["深蹲", "腿推", "腿彎舉", "腹部訓練"]
        case .fullBodyVolume:
            return ["深蹲", "臥推", "划船", "腹部訓練"]
        case .recovery:
            return ["滑輪下拉", "腿彎舉", "側平舉", "腹部訓練"]
        }
    }

    private func focusName(for splitType: TrainingSplitType) -> String {
        switch splitType {
        case .fullBody, .fullBodyA, .fullBodyB, .fullBodyC, .fullBodyVolume:
            return "全身"
        case .upperPush, .push:
            return "胸部 / 肩部"
        case .upperPull, .pull:
            return "背部"
        case .lowerBody, .legs:
            return "腿部"
        case .recovery:
            return "恢復"
        }
    }

    private func exercise(named name: String, in exercises: [Exercise]) -> Exercise? {
        exercises.first { $0.name == name }
    }

    private func latestExerciseLog(
        for exercise: Exercise,
        in records: [WorkoutSessionRecord]
    ) -> ExerciseLog? {
        records
            .flatMap(\.exerciseLogs)
            .first { $0.exercise.name == exercise.name }
    }

    private func plannedExercise(
        for exercise: Exercise,
        previousLog: ExerciseLog?
    ) -> PlannedExercise {
        plannedExerciseWithExplanation(
            for: exercise,
            previousLog: previousLog
        ).plannedExercise
    }

    private func plannedExerciseWithExplanation(
        for exercise: Exercise,
        previousLog: ExerciseLog?
    ) -> (plannedExercise: PlannedExercise, explanation: ExercisePlanExplanation) {
        let category = ExerciseProgressionRule.category(for: exercise.name)
        let defaults = defaultPrescription(for: exercise, category: category)

        guard let previousLog, !previousLog.sets.isEmpty else {
            let plannedExercise = PlannedExercise(
                exercise: exercise,
                targetSets: defaults.sets,
                targetReps: defaults.reps,
                suggestedWeightInKilograms: defaults.weight,
                targetRPE: ExerciseProgressionRule.defaultTargetRPE,
                targetRIR: ExerciseProgressionRule.defaultTargetRIR
            )
            let explanation = ExercisePlanExplanation(
                exerciseName: exercise.name,
                reason: "尚無此動作歷史紀錄，使用預設 \(defaults.sets) 組 x \(defaults.reps) 次與 \(formatWeight(defaults.weight))。",
                adjustment: .defaulted
            )

            return (plannedExercise, explanation)
        }

        let completedSets = previousLog.sets.filter(\.isCompleted)
        let performanceSets = completedSets.isEmpty ? previousLog.sets : completedSets
        let averageRPE = average(performanceSets.compactMap(\.rpe))
        let averageRIR = average(performanceSets.compactMap { $0.rir.map(Double.init) })
        let averageWeight = average(performanceSets.map(\.weightInKilograms)) ?? defaults.weight
        let averageReps = average(performanceSets.map { Double($0.reps) }) ?? Double(defaults.reps)
        let completedAllSets = completedSets.count == previousLog.sets.count
        let isFatigued = !completedAllSets || (averageRPE ?? 0) >= 9.5 || (averageRIR ?? 10) <= 0
        let isHardButCompleted = (8.5...9).contains(averageRPE ?? 0)
        let canProgress = completedAllSets && ((averageRPE ?? 10) <= 8 || (averageRIR ?? 0) >= 2)

        if isFatigued {
            let targetSets = max(previousLog.sets.count - 1, ExerciseProgressionRule.minimumTargetSets)
            let suggestedWeight = roundedWeight(averageWeight * ExerciseProgressionRule.fatigueLoadMultiplier)
            let plannedExercise = PlannedExercise(
                exercise: exercise,
                targetSets: targetSets,
                targetReps: max(Int(averageReps.rounded()), 1),
                suggestedWeightInKilograms: suggestedWeight,
                targetRPE: ExerciseProgressionRule.fatigueTargetRPE,
                targetRIR: ExerciseProgressionRule.fatigueTargetRIR
            )
            let explanation = ExercisePlanExplanation(
                exerciseName: exercise.name,
                reason: "上次出現疲勞訊號（\(fatigueReason(completedAllSets: completedAllSets, averageRPE: averageRPE, averageRIR: averageRIR)），重量由 \(formatWeight(averageWeight)) 下修 5% 至 \(formatWeight(suggestedWeight))，組數降至 \(targetSets) 組。",
                adjustment: .reduced
            )

            return (plannedExercise, explanation)
        }

        if isHardButCompleted {
            let suggestedWeight = roundedWeight(averageWeight)
            let plannedExercise = PlannedExercise(
                exercise: exercise,
                targetSets: previousLog.sets.count,
                targetReps: max(Int(averageReps.rounded()), 1),
                suggestedWeightInKilograms: suggestedWeight,
                targetRPE: ExerciseProgressionRule.defaultTargetRPE,
                targetRIR: ExerciseProgressionRule.defaultTargetRIR
            )
            let explanation = ExercisePlanExplanation(
                exerciseName: exercise.name,
                reason: "上次完成但平均 RPE \(formatOptionalDecimal(averageRPE)) 偏高，這次維持 \(formatWeight(suggestedWeight))，先穩住動作品質。",
                adjustment: .maintained
            )

            return (plannedExercise, explanation)
        }

        let progressedWeight = canProgress ? averageWeight + weightIncrease(for: category) : averageWeight
        let suggestedWeight = roundedWeight(progressedWeight)
        let plannedExercise = PlannedExercise(
            exercise: exercise,
            targetSets: previousLog.sets.count,
            targetReps: max(Int(averageReps.rounded()), 1),
            suggestedWeightInKilograms: suggestedWeight,
            targetRPE: ExerciseProgressionRule.defaultTargetRPE,
            targetRIR: ExerciseProgressionRule.defaultTargetRIR
        )

        if canProgress {
            let explanation = ExercisePlanExplanation(
                exerciseName: exercise.name,
                reason: "上次完成全部組數，且平均 RPE \(formatOptionalDecimal(averageRPE)) / RIR \(formatOptionalDecimal(averageRIR)) 顯示仍有餘裕，重量由 \(formatWeight(averageWeight)) 提升至 \(formatWeight(suggestedWeight))。",
                adjustment: .progressed
            )

            return (plannedExercise, explanation)
        }

        let explanation = ExercisePlanExplanation(
            exerciseName: exercise.name,
            reason: "上次表現沒有明顯疲勞，但也未達加重條件，這次維持 \(formatWeight(suggestedWeight))。",
            adjustment: .maintained
        )

        return (plannedExercise, explanation)
    }

    private func defaultPrescription(
        for exercise: Exercise,
        category: ExerciseProgressionCategory
    ) -> (sets: Int, reps: Int, weight: Double) {
        (
            sets: ExerciseProgressionRule.defaultSets(for: category),
            reps: ExerciseProgressionRule.defaultReps(for: category),
            weight: ExerciseProgressionRule.defaultWeight(for: exercise.name)
        )
    }

    private func weightIncrease(for category: ExerciseProgressionCategory) -> Double {
        switch category {
        case .primary:
            return ExerciseProgressionRule.primaryWeightIncrease
        case .accessory:
            return ExerciseProgressionRule.accessoryWeightIncrease
        case .bodyweightCore:
            return 0
        }
    }

    private func average(_ values: [Double]) -> Double? {
        guard !values.isEmpty else {
            return nil
        }

        return values.reduce(0, +) / Double(values.count)
    }

    private func roundedWeight(_ weight: Double) -> Double {
        max((weight * 2).rounded() / 2, 0)
    }

    private func summaryText(
        for splitType: TrainingSplitType,
        profile: UserProfile,
        latestRecord: WorkoutSessionRecord?
    ) -> String {
        guard let latestRecord else {
            return "目前沒有歷史訓練紀錄，因此先安排「\(splitType.displayName)」作為起始課表。"
        }

        let latestSplit = splitType(from: latestRecord)
        return "根據最近一次「\(latestSplit.displayName)」訓練，下一次安排「\(splitType.displayName)」。"
    }

    private func splitReasonText(
        for splitType: TrainingSplitType,
        weeklyTargetTrainingDays: Int,
        latestRecord: WorkoutSessionRecord?
    ) -> String {
        let strategy = strategyDescription(for: weeklyTargetTrainingDays)

        if let latestRecord {
            let latestSplit = splitType(from: latestRecord)
            return "每週目標 \(weeklyTargetTrainingDays) 天，使用\(strategy)。最近一次推估為「\(latestSplit.displayName)」，所以輪替到「\(splitType.displayName)」。"
        }

        return "每週目標 \(weeklyTargetTrainingDays) 天，使用\(strategy)。因尚無歷史紀錄，先從「\(splitType.displayName)」開始。"
    }

    private func historyReferenceText(from records: [WorkoutSessionRecord]) -> String {
        guard let latestRecord = records.first else {
            return "目前沒有可參考的歷史訓練紀錄。"
        }

        return "參考 \(records.count) 筆歷史訓練紀錄；最近一次是「\(latestRecord.title)」，日期 \(latestRecord.date.fitPlannerShortDate)。"
    }

    private func strategyDescription(for weeklyTargetTrainingDays: Int) -> String {
        switch weeklyTargetTrainingDays {
        case ...2:
            return "全身 A / B 輪替"
        case 3:
            return "全身 A / B / C 輪替"
        case 4...5:
            return "上肢推 / 上肢拉 / 下肢 / 全身容量輪替"
        default:
            return "推 / 拉 / 腿輪替"
        }
    }

    private func fatigueReason(
        completedAllSets: Bool,
        averageRPE: Double?,
        averageRIR: Double?
    ) -> String {
        var reasons: [String] = []

        if !completedAllSets {
            reasons.append("未完成全部組數")
        }

        if let averageRPE, averageRPE >= 9.5 {
            reasons.append("平均 RPE \(formatDecimal(averageRPE))")
        }

        if let averageRIR, averageRIR <= 0 {
            reasons.append("平均 RIR \(formatDecimal(averageRIR))")
        }

        return reasons.isEmpty ? "表現偏疲勞" : reasons.joined(separator: "、")
    }

    private func formatWeight(_ weight: Double) -> String {
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(weight)) kg"
        }

        return "\(formatDecimal(weight)) kg"
    }

    private func formatOptionalDecimal(_ value: Double?) -> String {
        guard let value else {
            return "-"
        }

        return formatDecimal(value)
    }

    private func formatDecimal(_ value: Double) -> String {
        String(format: "%.1f", value)
    }
}

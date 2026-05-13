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

    func generateNextWorkout(
        profile: UserProfile,
        workoutRecords: [WorkoutSessionRecord],
        exercises: [Exercise],
        preference: WorkoutGenerationPreference
    ) -> PlannedWorkoutDay {
        generateNextWorkoutWithExplanation(
            profile: profile,
            workoutRecords: workoutRecords,
            exercises: exercises,
            preference: preference
        ).plannedWorkoutDay
    }

    func generateNextWorkoutWithExplanation(
        profile: UserProfile,
        workoutRecords: [WorkoutSessionRecord],
        exercises: [Exercise],
        preference: WorkoutGenerationPreference
    ) -> (plannedWorkoutDay: PlannedWorkoutDay, explanation: PlanGenerationExplanation) {
        if preference.focusType == .recommended {
            return generateRecommendedWorkoutWithPreference(
                profile: profile,
                workoutRecords: workoutRecords,
                exercises: exercises,
                preference: preference
            )
        }

        let sortedRecords = workoutRecords.sorted { $0.date > $1.date }
        let selectedExercises = selectExercises(
            from: exercises,
            focusType: preference.focusType,
            availableEquipment: preference.availableEquipment,
            trainingStyle: preference.trainingStyle
        )
        let exerciseResults = selectedExercises.map { exercise in
            plannedExerciseWithExplanation(
                for: exercise,
                previousLog: latestExerciseLog(for: exercise, in: sortedRecords),
                trainingStyle: preference.trainingStyle
            )
        }
        let title = "\(preference.focusType.displayName)・\(preference.trainingStyle.displayName)"
        let plannedWorkoutDay = PlannedWorkoutDay(
            date: Date(),
            title: title,
            focus: preference.focusType.displayName,
            plannedExercises: exerciseResults.map { $0.plannedExercise }
        )
        let explanation = PlanGenerationExplanation(
            summary: "依照今天選擇的「\(preference.focusType.displayName)」與「\(preference.trainingStyle.displayName)」產生課表。",
            splitReason: "可用器材：\(equipmentSummary(preference.availableEquipment))。系統優先挑選符合目標肌群、器材與訓練方式的動作。",
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

    private func generateRecommendedWorkoutWithPreference(
        profile: UserProfile,
        workoutRecords: [WorkoutSessionRecord],
        exercises: [Exercise],
        preference: WorkoutGenerationPreference
    ) -> (plannedWorkoutDay: PlannedWorkoutDay, explanation: PlanGenerationExplanation) {
        let sortedRecords = workoutRecords.sorted { $0.date > $1.date }
        let splitType = nextSplitType(
            weeklyTargetTrainingDays: profile.weeklyTargetTrainingDays,
            latestRecord: sortedRecords.first
        )
        let focusType = workoutFocusType(for: splitType)
        let selectedExercises = selectExercises(
            from: exercises,
            focusType: focusType,
            availableEquipment: preference.availableEquipment,
            trainingStyle: preference.trainingStyle,
            fallbackNames: exerciseNames(for: splitType)
        )
        let exerciseResults = selectedExercises.map { exercise in
            plannedExerciseWithExplanation(
                for: exercise,
                previousLog: latestExerciseLog(for: exercise, in: sortedRecords),
                trainingStyle: preference.trainingStyle
            )
        }

        let plannedWorkoutDay = PlannedWorkoutDay(
            date: Date(),
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
            ) + " 可用器材：\(equipmentSummary(preference.availableEquipment))；訓練方式：\(preference.trainingStyle.displayName)。",
            historyReference: historyReferenceText(from: sortedRecords),
            exerciseReasons: exerciseResults.map { $0.explanation }
        )

        return (plannedWorkoutDay, explanation)
    }

    private func selectExercises(
        from exercises: [Exercise],
        focusType: WorkoutFocusType,
        availableEquipment: [EquipmentType],
        trainingStyle: TrainingStyle,
        fallbackNames: [String] = []
    ) -> [Exercise] {
        let equipmentFiltered = exercises.filter { exercise in
            matchesEquipment(exercise, availableEquipment: availableEquipment)
        }
        let focusFiltered = equipmentFiltered.filter { exercise in
            matchesFocus(exercise, focusType: focusType)
        }
        let strictMatches = focusFiltered.filter { exercise in
            matchesTrainingStyle(exercise, trainingStyle: trainingStyle)
        }

        let fallbackByName = fallbackNames
            .compactMap { exercise(named: $0, in: equipmentFiltered) }
            .filter { matchesTrainingStyle($0, trainingStyle: trainingStyle) || strictMatches.isEmpty }

        return uniqueExercises(strictMatches + fallbackByName + focusFiltered)
            .sorted { lhs, rhs in
                if lhs.isCompound != rhs.isCompound {
                    return lhs.isCompound && trainingStyle != .recovery
                }

                return lhs.name < rhs.name
            }
            .prefix(4)
            .map { $0 }
    }

    private func matchesEquipment(
        _ exercise: Exercise,
        availableEquipment: [EquipmentType]
    ) -> Bool {
        guard !availableEquipment.isEmpty else {
            return true
        }

        return !Set(exercise.equipmentTypes).isDisjoint(with: Set(availableEquipment))
    }

    private func matchesFocus(
        _ exercise: Exercise,
        focusType: WorkoutFocusType
    ) -> Bool {
        if focusType == .custom {
            return true
        }

        if exercise.supportedFocusTypes.contains(focusType) {
            return true
        }

        switch focusType {
        case .push:
            return exercise.primaryMuscleGroups.contains(.chest) || exercise.primaryMuscleGroups.contains(.shoulders) || exercise.primaryMuscleGroups.contains(.triceps)
        case .pull:
            return exercise.primaryMuscleGroups.contains(.back) || exercise.primaryMuscleGroups.contains(.biceps)
        case .legs:
            return exercise.primaryMuscleGroups.contains(.quads) || exercise.primaryMuscleGroups.contains(.hamstrings) || exercise.primaryMuscleGroups.contains(.glutes) || exercise.primaryMuscleGroups.contains(.calves)
        case .fullBody, .recommended:
            return exercise.isCompound || exercise.primaryMuscleGroups.contains(.core)
        case .chest:
            return exercise.primaryMuscleGroups.contains(.chest)
        case .back:
            return exercise.primaryMuscleGroups.contains(.back)
        case .shoulders:
            return exercise.primaryMuscleGroups.contains(.shoulders)
        case .arms:
            return exercise.primaryMuscleGroups.contains(.biceps) || exercise.primaryMuscleGroups.contains(.triceps)
        case .core:
            return exercise.primaryMuscleGroups.contains(.core)
        case .custom:
            return true
        }
    }

    private func matchesTrainingStyle(
        _ exercise: Exercise,
        trainingStyle: TrainingStyle
    ) -> Bool {
        trainingStyle == .custom || exercise.supportedTrainingStyles.contains(trainingStyle)
    }

    private func uniqueExercises(_ exercises: [Exercise]) -> [Exercise] {
        var seenIDs: Set<UUID> = []
        var result: [Exercise] = []

        for exercise in exercises where !seenIDs.contains(exercise.id) {
            seenIDs.insert(exercise.id)
            result.append(exercise)
        }

        return result
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
            return ["深蹲", "槓鈴臥推", "槓鈴划船", "捲腹"]
        case .fullBodyB:
            return ["羅馬尼亞硬舉", "肩推", "滑輪下拉", "腿彎舉"]
        case .fullBodyC:
            return ["腿推", "啞鈴臥推", "坐姿划船", "側平舉"]
        case .upperPush, .push:
            return ["槓鈴臥推", "肩推", "側平舉", "繩索下壓"]
        case .upperPull, .pull:
            return ["引體向上", "槓鈴划船", "滑輪下拉", "二頭彎舉"]
        case .lowerBody, .legs:
            return ["深蹲", "腿推", "腿彎舉", "小腿提踵"]
        case .fullBodyVolume:
            return ["深蹲", "機械胸推", "坐姿划船", "平板支撐"]
        case .recovery:
            return ["滑輪下拉", "腿彎舉", "側平舉", "平板支撐"]
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

    private func workoutFocusType(for splitType: TrainingSplitType) -> WorkoutFocusType {
        switch splitType {
        case .fullBody, .fullBodyA, .fullBodyB, .fullBodyC, .fullBodyVolume:
            return .fullBody
        case .upperPush, .push:
            return .push
        case .upperPull, .pull:
            return .pull
        case .lowerBody, .legs:
            return .legs
        case .recovery:
            return .fullBody
        }
    }

    private func equipmentSummary(_ equipmentTypes: [EquipmentType]) -> String {
        if equipmentTypes.isEmpty || equipmentTypes.count == EquipmentType.allCases.count {
            return "全部器材"
        }

        return equipmentTypes.map(\.displayName).joined(separator: "、")
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
        previousLog: ExerciseLog?,
        trainingStyle: TrainingStyle = .hypertrophy
    ) -> (plannedExercise: PlannedExercise, explanation: ExercisePlanExplanation) {
        let category = ExerciseProgressionRule.category(for: exercise.name)
        let defaults = defaultPrescription(for: exercise, category: category, trainingStyle: trainingStyle)

        guard let previousLog, !previousLog.sets.isEmpty else {
            let plannedExercise = PlannedExercise(
                exercise: exercise,
                targetSets: defaults.sets,
                targetReps: defaults.reps,
                suggestedWeightInKilograms: defaults.weight,
                targetRPE: defaults.rpe,
                targetRIR: defaults.rir
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
            let targetSets = max(min(defaults.sets, previousLog.sets.count) - 1, ExerciseProgressionRule.minimumTargetSets)
            let suggestedWeight = roundedWeight(averageWeight * fatigueMultiplier(for: trainingStyle))
            let plannedExercise = PlannedExercise(
                exercise: exercise,
                targetSets: targetSets,
                targetReps: defaults.reps,
                suggestedWeightInKilograms: suggestedWeight,
                targetRPE: fatigueTargetRPE(for: trainingStyle),
                targetRIR: fatigueTargetRIR(for: trainingStyle)
            )
            let fatigueText = fatigueReason(
                completedAllSets: completedAllSets,
                averageRPE: averageRPE,
                averageRIR: averageRIR
            )
            let explanation = ExercisePlanExplanation(
                exerciseName: exercise.name,
                reason: "上次出現疲勞訊號（\(fatigueText)），重量由 \(formatWeight(averageWeight)) 下修 5% 至 \(formatWeight(suggestedWeight))，組數降至 \(targetSets) 組。",
                adjustment: .reduced
            )

            return (plannedExercise, explanation)
        }

        if isHardButCompleted {
            let suggestedWeight = roundedWeight(averageWeight)
            let plannedExercise = PlannedExercise(
                exercise: exercise,
                targetSets: defaults.sets,
                targetReps: defaults.reps,
                suggestedWeightInKilograms: suggestedWeight,
                targetRPE: defaults.rpe,
                targetRIR: defaults.rir
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
            targetSets: defaults.sets,
            targetReps: defaults.reps,
            suggestedWeightInKilograms: suggestedWeight,
            targetRPE: defaults.rpe,
            targetRIR: defaults.rir
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
        category: ExerciseProgressionCategory,
        trainingStyle: TrainingStyle
    ) -> (sets: Int, reps: Int, weight: Double, rpe: Double, rir: Int) {
        let baseSets = max(exercise.defaultSets, ExerciseProgressionRule.defaultSets(for: category))
        let baseReps = max(exercise.defaultReps, 1)
        let baseWeight = ExerciseProgressionRule.defaultWeight(for: exercise.name)

        switch trainingStyle {
        case .strength:
            return (
                sets: min(max(baseSets, 3), 5),
                reps: min(max(baseReps, 3), 6),
                weight: baseWeight,
                rpe: 8,
                rir: 2
            )
        case .hypertrophy, .custom:
            return (
                sets: min(max(baseSets, 3), 4),
                reps: min(max(baseReps, 8), 12),
                weight: baseWeight,
                rpe: 8,
                rir: 2
            )
        case .endurance:
            return (
                sets: min(max(baseSets, 2), 4),
                reps: min(max(baseReps, 12), 20),
                weight: roundedWeight(baseWeight * 0.8),
                rpe: 7.5,
                rir: 3
            )
        case .recovery:
            return (
                sets: 2,
                reps: min(max(baseReps, 10), 15),
                weight: roundedWeight(baseWeight * 0.6),
                rpe: 6.5,
                rir: 4
            )
        }
    }

    private func fatigueMultiplier(for trainingStyle: TrainingStyle) -> Double {
        switch trainingStyle {
        case .recovery:
            return 0.7
        case .endurance:
            return 0.85
        default:
            return ExerciseProgressionRule.fatigueLoadMultiplier
        }
    }

    private func fatigueTargetRPE(for trainingStyle: TrainingStyle) -> Double {
        trainingStyle == .recovery ? 6.5 : ExerciseProgressionRule.fatigueTargetRPE
    }

    private func fatigueTargetRIR(for trainingStyle: TrainingStyle) -> Int {
        trainingStyle == .recovery ? 4 : ExerciseProgressionRule.fatigueTargetRIR
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
        for selectedSplitType: TrainingSplitType,
        profile: UserProfile,
        latestRecord: WorkoutSessionRecord?
    ) -> String {
        guard let latestRecord else {
            return "目前沒有歷史訓練紀錄，因此先安排「\(selectedSplitType.displayName)」作為起始課表。"
        }

        let latestSplit = splitType(from: latestRecord)
        return "根據最近一次「\(latestSplit.displayName)」訓練，下一次安排「\(selectedSplitType.displayName)」。"
    }

    private func splitReasonText(
        for selectedSplitType: TrainingSplitType,
        weeklyTargetTrainingDays: Int,
        latestRecord: WorkoutSessionRecord?
    ) -> String {
        let strategy = strategyDescription(for: weeklyTargetTrainingDays)

        if let latestRecord {
            let latestSplit = splitType(from: latestRecord)
            return "每週目標 \(weeklyTargetTrainingDays) 天，使用\(strategy)。最近一次推估為「\(latestSplit.displayName)」，所以輪替到「\(selectedSplitType.displayName)」。"
        }

        return "每週目標 \(weeklyTargetTrainingDays) 天，使用\(strategy)。因尚無歷史紀錄，先從「\(selectedSplitType.displayName)」開始。"
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

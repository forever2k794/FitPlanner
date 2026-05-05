import Foundation

enum MockGeneratedPlan {
    static var nextWeekPlan: GeneratedPlan {
        let today = Date().fitPlannerStartOfDay
        let weekStart = today.fitPlannerStartOfWeek
        let todayIndex = Calendar.fitPlanner.dateComponents([.day], from: weekStart, to: today).day ?? 0

        let days = (0..<7).map { index -> PlannedWorkoutDay in
            let date = weekStart.addingFitPlannerDays(index)

            if [2, 6].contains(index), index != todayIndex {
                return PlannedWorkoutDay(
                    date: date,
                    title: "休息日",
                    focus: "恢復",
                    plannedExercises: []
                )
            }

            switch index % 4 {
            case 0:
                return PlannedWorkoutDay(
                    date: date,
                    title: "下肢力量",
                    focus: "腿部",
                    plannedExercises: [
                        plannedExercise("深蹲", sets: 4, reps: 5, weight: 92.5, rpe: 8, rir: 2),
                        plannedExercise("腿推", sets: 3, reps: 10, weight: 155, rpe: 8, rir: 2),
                        plannedExercise("腿彎舉", sets: 3, reps: 12, weight: 45, rpe: 8, rir: 2),
                        plannedExercise("腹部訓練", sets: 3, reps: 15, weight: 0, rpe: 7, rir: 3)
                    ]
                )
            case 1:
                return PlannedWorkoutDay(
                    date: date,
                    title: "上肢推",
                    focus: "胸部 / 肩部",
                    plannedExercises: [
                        plannedExercise("臥推", sets: 4, reps: 6, weight: 72.5, rpe: 8, rir: 2),
                        plannedExercise("肩推", sets: 3, reps: 8, weight: 22, rpe: 8, rir: 2),
                        plannedExercise("側平舉", sets: 3, reps: 15, weight: 8, rpe: 8, rir: 2)
                    ]
                )
            case 2:
                return PlannedWorkoutDay(
                    date: date,
                    title: "上肢拉",
                    focus: "背部",
                    plannedExercises: [
                        plannedExercise("硬舉", sets: 3, reps: 4, weight: 112.5, rpe: 8, rir: 2),
                        plannedExercise("划船", sets: 4, reps: 8, weight: 62.5, rpe: 8, rir: 2),
                        plannedExercise("滑輪下拉", sets: 3, reps: 10, weight: 57.5, rpe: 8, rir: 2)
                    ]
                )
            default:
                return PlannedWorkoutDay(
                    date: date,
                    title: "全身容量",
                    focus: "全身",
                    plannedExercises: [
                        plannedExercise("深蹲", sets: 3, reps: 8, weight: 80, rpe: 7.5, rir: 3),
                        plannedExercise("臥推", sets: 3, reps: 8, weight: 65, rpe: 7.5, rir: 3),
                        plannedExercise("划船", sets: 3, reps: 10, weight: 55, rpe: 8, rir: 2),
                        plannedExercise("腹部訓練", sets: 3, reps: 15, weight: 0, rpe: 7, rir: 3)
                    ]
                )
            }
        }

        return GeneratedPlan(
            name: "第一週基礎課表",
            weekStartDate: weekStart,
            days: days
        )
    }

    private static func plannedExercise(
        _ name: String,
        sets: Int,
        reps: Int,
        weight: Double,
        rpe: Double,
        rir: Int
    ) -> PlannedExercise {
        PlannedExercise(
            exercise: MockExercises.exercise(named: name),
            targetSets: sets,
            targetReps: reps,
            suggestedWeightInKilograms: weight,
            targetRPE: rpe,
            targetRIR: rir
        )
    }
}

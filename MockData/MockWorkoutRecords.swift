import Foundation

enum MockWorkoutRecords {
    static var history: [WorkoutSessionRecord] {
        let today = Date()

        return [
            WorkoutSessionRecord(
                title: "下肢力量日",
                date: today.addingFitPlannerDays(-6),
                exerciseLogs: [
                    exerciseLog(name: "深蹲", weight: 90, reps: 5, sets: 4, rpe: 8, rir: 2),
                    exerciseLog(name: "腿推", weight: 150, reps: 10, sets: 3, rpe: 8, rir: 2),
                    exerciseLog(name: "腿彎舉", weight: 45, reps: 12, sets: 3, rpe: 7.5, rir: 2)
                ],
                note: "深蹲速度穩定，下週可小幅加重。"
            ),
            WorkoutSessionRecord(
                title: "上肢推",
                date: today.addingFitPlannerDays(-4),
                exerciseLogs: [
                    exerciseLog(name: "臥推", weight: 70, reps: 6, sets: 4, rpe: 8, rir: 2),
                    exerciseLog(name: "肩推", weight: 22, reps: 8, sets: 3, rpe: 8, rir: 2),
                    exerciseLog(name: "側平舉", weight: 8, reps: 15, sets: 3, rpe: 8.5, rir: 1)
                ],
                note: "肩推最後一組稍吃力。"
            ),
            WorkoutSessionRecord(
                title: "上肢拉",
                date: today.addingFitPlannerDays(-2),
                exerciseLogs: [
                    exerciseLog(name: "硬舉", weight: 110, reps: 4, sets: 3, rpe: 8, rir: 2),
                    exerciseLog(name: "划船", weight: 60, reps: 8, sets: 4, rpe: 8, rir: 2),
                    exerciseLog(name: "滑輪下拉", weight: 55, reps: 10, sets: 3, rpe: 7.5, rir: 2)
                ],
                note: "硬舉保留次數充足，動作品質佳。"
            )
        ]
    }

    private static func exerciseLog(
        name: String,
        weight: Double,
        reps: Int,
        sets: Int,
        rpe: Double,
        rir: Int
    ) -> ExerciseLog {
        let setLogs = (1...sets).map { setNumber in
            SetLog(
                setNumber: setNumber,
                weightInKilograms: weight,
                reps: reps,
                rpe: rpe,
                rir: rir,
                isCompleted: true
            )
        }

        return ExerciseLog(
            exercise: MockExercises.exercise(named: name),
            sets: setLogs
        )
    }
}

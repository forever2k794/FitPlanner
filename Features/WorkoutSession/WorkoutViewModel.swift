import Combine
import Foundation

@MainActor
final class WorkoutViewModel: ObservableObject {
    @Published private(set) var plannedWorkoutDay: PlannedWorkoutDay?
    @Published private(set) var hasCompletedToday: Bool
    @Published var completionMessage: String?

    private let fitnessService: FitnessService

    init(fitnessService: FitnessService) {
        self.fitnessService = fitnessService
        self.plannedWorkoutDay = fitnessService.todayPlannedWorkout()
        self.hasCompletedToday = fitnessService.hasCompletedWorkout()
    }

    func refresh() {
        plannedWorkoutDay = fitnessService.todayPlannedWorkout()
        hasCompletedToday = fitnessService.hasCompletedWorkout()
    }

    func completeTodayWorkout() {
        guard let plannedWorkoutDay, !plannedWorkoutDay.isRestDay else {
            completionMessage = "今天沒有可完成的訓練課表。"
            return
        }

        guard !hasCompletedToday else {
            completionMessage = "今日訓練已完成。"
            return
        }

        let record = fitnessService.completeWorkout(for: plannedWorkoutDay)
        hasCompletedToday = true
        completionMessage = "已新增「\(record.title)」訓練紀錄。"
    }
}

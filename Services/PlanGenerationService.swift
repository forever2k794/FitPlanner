import Foundation

final class PlanGenerationService {
    private let repository: FitnessRepository

    init(repository: FitnessRepository) {
        self.repository = repository
    }

    func currentPlan() -> GeneratedPlan {
        repository.fetchGeneratedPlan()
    }

    func plannedWorkout(on date: Date = Date()) -> PlannedWorkoutDay? {
        repository.plannedWorkout(on: date)
    }

    func nextPlannedWorkout(from date: Date = Date()) -> PlannedWorkoutDay? {
        repository.nextPlannedWorkout(from: date)
    }
}

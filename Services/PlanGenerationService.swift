import Foundation

final class PlanGenerationService {
    private let repository: FitnessRepository
    private let ruleBasedPlanGenerationService: RuleBasedPlanGenerationService

    init(
        repository: FitnessRepository,
        ruleBasedPlanGenerationService: RuleBasedPlanGenerationService = RuleBasedPlanGenerationService()
    ) {
        self.repository = repository
        self.ruleBasedPlanGenerationService = ruleBasedPlanGenerationService
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

    func generateNextWorkout() -> PlannedWorkoutDay {
        ruleBasedPlanGenerationService.generateNextWorkout(
            profile: repository.fetchUserProfile(),
            workoutRecords: repository.fetchWorkoutRecords(),
            exercises: repository.fetchExercises()
        )
    }
}

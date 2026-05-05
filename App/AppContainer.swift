import Combine
import Foundation

@MainActor
final class AppContainer: ObservableObject {
    let repository: FitnessRepository
    let fitnessService: FitnessService
    let planGenerationService: PlanGenerationService
    let progressSummaryService: ProgressSummaryService

    init(repository: FitnessRepository = InMemoryFitnessRepository()) {
        self.repository = repository
        self.fitnessService = FitnessService(repository: repository)
        self.planGenerationService = PlanGenerationService(repository: repository)
        self.progressSummaryService = ProgressSummaryService(repository: repository)
    }

    static func preview() -> AppContainer {
        AppContainer(repository: InMemoryFitnessRepository())
    }
}

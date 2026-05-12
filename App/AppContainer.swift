import Combine
import Foundation

@MainActor
final class AppContainer: ObservableObject {
    let repository: FitnessRepository
    let fitnessService: FitnessService
    let planGenerationService: PlanGenerationService
    let progressSummaryService: ProgressSummaryService
    let backupExportService: BackupExportService
    let backupImportService: BackupImportService

    init(repository: FitnessRepository = JSONFitnessRepository()) {
        self.repository = repository
        let fitnessService = FitnessService(repository: repository)
        self.fitnessService = fitnessService
        self.planGenerationService = PlanGenerationService(repository: repository)
        self.progressSummaryService = ProgressSummaryService(repository: repository)
        self.backupExportService = BackupExportService(fitnessService: fitnessService)
        self.backupImportService = BackupImportService(fitnessService: fitnessService)
    }

    static func preview() -> AppContainer {
        AppContainer(repository: InMemoryFitnessRepository())
    }
}

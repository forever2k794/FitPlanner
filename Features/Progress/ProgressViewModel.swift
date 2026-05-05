import Combine
import Foundation

@MainActor
final class ProgressViewModel: ObservableObject {
    @Published private(set) var summary: ProgressSummary

    private let progressSummaryService: ProgressSummaryService

    init(progressSummaryService: ProgressSummaryService) {
        self.progressSummaryService = progressSummaryService
        self.summary = progressSummaryService.progressSummary()
    }

    func refresh() {
        summary = progressSummaryService.progressSummary()
    }
}

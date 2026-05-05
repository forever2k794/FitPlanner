import Combine
import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published private(set) var summary: DashboardSummary

    private let progressSummaryService: ProgressSummaryService

    init(progressSummaryService: ProgressSummaryService) {
        self.progressSummaryService = progressSummaryService
        self.summary = progressSummaryService.dashboardSummary()
    }

    func refresh() {
        summary = progressSummaryService.dashboardSummary()
    }
}

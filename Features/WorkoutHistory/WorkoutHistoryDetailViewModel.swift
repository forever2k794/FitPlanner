import Combine
import Foundation

@MainActor
final class WorkoutHistoryDetailViewModel: ObservableObject {
    @Published private(set) var session: WorkoutSessionRecord
    @Published private(set) var canEdit: Bool

    private let fitnessService: FitnessService

    init(
        session: WorkoutSessionRecord,
        fitnessService: FitnessService
    ) {
        self.session = session
        self.fitnessService = fitnessService
        self.canEdit = fitnessService.canEditWorkoutRecord(id: session.id)
    }

    func save(_ updatedSession: WorkoutSessionRecord) {
        guard canEdit else {
            return
        }

        fitnessService.updateWorkoutRecord(updatedSession)
        session = updatedSession
        canEdit = fitnessService.canEditWorkoutRecord(id: updatedSession.id)
    }
}

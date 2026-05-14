import Combine
import Foundation

@MainActor
final class WorkoutHistoryDetailViewModel: ObservableObject {
    @Published private(set) var session: WorkoutSessionRecord
    @Published private(set) var canEdit: Bool
    @Published private(set) var canDelete: Bool
    @Published private(set) var saveMessage: String?
    @Published private(set) var didSaveSuccessfully: Bool

    private let fitnessService: FitnessService
    private let onSave: (() -> Void)?
    private let onDelete: (() -> Void)?

    init(
        session: WorkoutSessionRecord,
        fitnessService: FitnessService,
        onSave: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.session = session
        self.fitnessService = fitnessService
        self.onSave = onSave
        self.onDelete = onDelete
        self.canEdit = fitnessService.canEditWorkoutRecord(id: session.id)
        self.canDelete = fitnessService.canDeleteWorkoutRecord(id: session.id)
        self.saveMessage = nil
        self.didSaveSuccessfully = false
    }

    func save(_ updatedSession: WorkoutSessionRecord) {
        guard canEdit else {
            saveMessage = "這筆範例紀錄不可編輯。"
            didSaveSuccessfully = false
            return
        }

        fitnessService.updateWorkoutRecord(updatedSession)
        session = updatedSession
        canEdit = fitnessService.canEditWorkoutRecord(id: updatedSession.id)
        canDelete = fitnessService.canDeleteWorkoutRecord(id: updatedSession.id)
        saveMessage = "訓練紀錄已更新。"
        didSaveSuccessfully = true
        onSave?()
    }

    func deleteSession() -> Bool {
        guard canDelete else {
            saveMessage = "這筆範例紀錄不可刪除。"
            didSaveSuccessfully = false
            return false
        }

        fitnessService.deleteWorkoutRecord(id: session.id)
        onDelete?()
        return true
    }
}

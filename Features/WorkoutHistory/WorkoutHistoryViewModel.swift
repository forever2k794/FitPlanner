import Combine
import Foundation

@MainActor
final class WorkoutHistoryViewModel: ObservableObject {
    @Published private(set) var records: [WorkoutSessionRecord]

    private let fitnessService: FitnessService

    init(fitnessService: FitnessService) {
        self.fitnessService = fitnessService
        self.records = []
        refresh()
    }

    func refresh() {
        records = fitnessService.workoutRecords().sorted { $0.date > $1.date }
    }

    func delete(record: WorkoutSessionRecord) {
        guard canDelete(record) else {
            return
        }

        fitnessService.deleteWorkoutRecord(id: record.id)
        refresh()
    }

    func canDelete(_ record: WorkoutSessionRecord) -> Bool {
        fitnessService.canDeleteWorkoutRecord(id: record.id)
    }

    func detailViewModel(for record: WorkoutSessionRecord) -> WorkoutHistoryDetailViewModel {
        WorkoutHistoryDetailViewModel(
            session: record,
            fitnessService: fitnessService,
            onSave: { [weak self] in
                self?.refresh()
            },
            onDelete: { [weak self] in
                self?.refresh()
            }
        )
    }

    func exerciseCount(for record: WorkoutSessionRecord) -> Int {
        record.exerciseLogs.count
    }

    func completedSetCount(for record: WorkoutSessionRecord) -> Int {
        record.exerciseLogs.reduce(0) { count, exerciseLog in
            count + exerciseLog.sets.filter(\.isCompleted).count
        }
    }

    func totalSetCount(for record: WorkoutSessionRecord) -> Int {
        record.exerciseLogs.reduce(0) { count, exerciseLog in
            count + exerciseLog.sets.count
        }
    }

    func totalVolume(for record: WorkoutSessionRecord) -> Double {
        record.totalVolume
    }
}

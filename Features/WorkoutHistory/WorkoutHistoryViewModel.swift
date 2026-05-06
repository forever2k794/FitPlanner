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

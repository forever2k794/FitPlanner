import Combine
import Foundation

enum PlanCalendarDayStatus: String {
    case completed = "已完成"
    case planned = "預計訓練"
    case rest = "休息日"
}

struct PlanCalendarDayItem: Identifiable, Hashable {
    let id: UUID
    var date: Date
    var title: String
    var focus: String
    var exerciseCount: Int
    var status: PlanCalendarDayStatus

    var isToday: Bool {
        date.isSameFitPlannerDay(as: Date())
    }
}

@MainActor
final class PlanCalendarViewModel: ObservableObject {
    @Published private(set) var planName: String
    @Published private(set) var weekRangeTitle: String
    @Published private(set) var days: [PlanCalendarDayItem]

    private let planGenerationService: PlanGenerationService
    private let fitnessService: FitnessService

    init(
        planGenerationService: PlanGenerationService,
        fitnessService: FitnessService
    ) {
        self.planGenerationService = planGenerationService
        self.fitnessService = fitnessService
        self.planName = ""
        self.weekRangeTitle = ""
        self.days = []
        refresh()
    }

    func refresh() {
        let plan = planGenerationService.currentPlan()
        let records = fitnessService.workoutRecords()

        planName = plan.name
        weekRangeTitle = "\(plan.weekStartDate.fitPlannerShortDate) - \(plan.weekStartDate.addingFitPlannerDays(6).fitPlannerShortDate)"
        days = plan.days
            .sorted { $0.date < $1.date }
            .map { plannedDay in
                let hasCompletedRecord = records.contains {
                    $0.date.isSameFitPlannerDay(as: plannedDay.date) && $0.isCompleted
                }

                let status: PlanCalendarDayStatus
                if plannedDay.isRestDay {
                    status = .rest
                } else if hasCompletedRecord {
                    status = .completed
                } else {
                    status = .planned
                }

                return PlanCalendarDayItem(
                    id: plannedDay.id,
                    date: plannedDay.date,
                    title: plannedDay.title,
                    focus: plannedDay.focus,
                    exerciseCount: plannedDay.plannedExercises.count,
                    status: status
                )
            }
    }
}

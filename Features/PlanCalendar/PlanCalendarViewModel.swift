import Combine
import Foundation

@MainActor
final class PlanCalendarViewModel: ObservableObject {
    @Published private(set) var monthTitle: String
    @Published private(set) var days: [CalendarDaySummary]
    @Published private(set) var selectedDate: Date
    @Published private(set) var selectedWorkoutRecords: [WorkoutSessionRecord]
    @Published private(set) var selectedPlannedWorkout: PlannedWorkoutDay?

    private let planGenerationService: PlanGenerationService
    private let fitnessService: FitnessService
    private var displayedMonth: Date

    init(
        planGenerationService: PlanGenerationService,
        fitnessService: FitnessService
    ) {
        self.planGenerationService = planGenerationService
        self.fitnessService = fitnessService
        let today = Date()
        self.displayedMonth = Self.startOfMonth(for: today)
        self.selectedDate = today.fitPlannerStartOfDay
        self.monthTitle = ""
        self.days = []
        self.selectedWorkoutRecords = []
        self.selectedPlannedWorkout = nil
        refresh()
    }

    func refresh() {
        let records = fitnessService.workoutRecords()
        let plan = planGenerationService.currentPlan()
        let plannedWorkoutsByDay = Dictionary(
            plan.days.map { (Self.dayKey(for: $0.date), $0) },
            uniquingKeysWith: { first, _ in first }
        )
        let recordsByDay = Dictionary(grouping: records) { record in
            Self.dayKey(for: record.date)
        }

        monthTitle = Self.monthTitle(for: displayedMonth)
        selectedWorkoutRecords = (recordsByDay[Self.dayKey(for: selectedDate)] ?? [])
            .sorted { $0.date > $1.date }
        selectedPlannedWorkout = plannedWorkoutsByDay[Self.dayKey(for: selectedDate)]
        days = Self.monthGridDates(for: displayedMonth).map { date in
            let key = Self.dayKey(for: date)
            let dayRecords = recordsByDay[key] ?? []
            let plannedWorkout = plannedWorkoutsByDay[key]

            return CalendarDaySummary(
                date: key,
                isInDisplayedMonth: Self.isDate(key, inSameMonthAs: displayedMonth),
                hasWorkoutRecord: !dayRecords.isEmpty,
                workoutTitle: Self.workoutTitle(for: dayRecords),
                totalVolume: dayRecords.reduce(0) { $0 + $1.totalVolume },
                completedSetCount: Self.completedSetCount(for: dayRecords),
                hasPlannedWorkout: plannedWorkout.map { !$0.isRestDay } ?? false,
                plannedTitle: plannedWorkout?.title,
                plannedFocus: plannedWorkout?.focus,
                plannedExerciseCount: plannedWorkout?.plannedExercises.count ?? 0,
                isRestDay: plannedWorkout?.isRestDay ?? false,
                isToday: key.isSameFitPlannerDay(as: Date()),
                isSelected: key.isSameFitPlannerDay(as: selectedDate)
            )
        }
    }

    func showPreviousMonth() {
        displayedMonth = Self.addMonths(-1, to: displayedMonth)
        selectedDate = displayedMonth
        refresh()
    }

    func showNextMonth() {
        displayedMonth = Self.addMonths(1, to: displayedMonth)
        selectedDate = displayedMonth
        refresh()
    }

    func selectDate(_ date: Date) {
        selectedDate = date.fitPlannerStartOfDay
        refresh()
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

    var selectedDateTitle: String {
        Self.selectedDateTitle(for: selectedDate)
    }

    private static func completedSetCount(for records: [WorkoutSessionRecord]) -> Int {
        records
            .flatMap(\.exerciseLogs)
            .flatMap(\.sets)
            .filter(\.isCompleted)
            .count
    }

    private static func workoutTitle(for records: [WorkoutSessionRecord]) -> String? {
        if records.count == 1 {
            return records.first?.title
        }

        if records.count > 1 {
            return "\(records.count) 筆訓練紀錄"
        }

        return nil
    }

    private static func monthGridDates(for month: Date) -> [Date] {
        let monthStart = startOfMonth(for: month)
        let weekday = calendar.component(.weekday, from: monthStart)
        let leadingDays = weekday - 1
        let gridStart = calendar.date(
            byAdding: .day,
            value: -leadingDays,
            to: monthStart
        ) ?? monthStart

        return (0..<42).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: gridStart)
        }
    }

    private static func startOfMonth(for date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? calendar.startOfDay(for: date)
    }

    private static func addMonths(_ value: Int, to date: Date) -> Date {
        let nextMonth = calendar.date(byAdding: .month, value: value, to: date) ?? date
        return startOfMonth(for: nextMonth)
    }

    private static func dayKey(for date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    private static func isDate(_ date: Date, inSameMonthAs month: Date) -> Bool {
        calendar.isDate(date, equalTo: month, toGranularity: .month)
    }

    private static func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hant_TW")
        formatter.dateFormat = "yyyy 年 M 月"
        return formatter.string(from: date)
    }

    private static func selectedDateTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hant_TW")
        formatter.dateFormat = "M 月 d 日 EEEE"
        return formatter.string(from: date)
    }

    private static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "zh_Hant_TW")
        calendar.firstWeekday = 1
        return calendar
    }
}

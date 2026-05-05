import Foundation

extension Calendar {
    static var fitPlanner: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        return calendar
    }
}

extension Date {
    var fitPlannerStartOfDay: Date {
        Calendar.fitPlanner.startOfDay(for: self)
    }

    var fitPlannerStartOfWeek: Date {
        let calendar = Calendar.fitPlanner
        let startOfDay = calendar.startOfDay(for: self)
        let weekday = calendar.component(.weekday, from: startOfDay)
        let daysFromMonday = (weekday + 5) % 7
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: startOfDay) ?? startOfDay
    }

    var fitPlannerEndOfWeek: Date {
        Calendar.fitPlanner.date(byAdding: .day, value: 7, to: fitPlannerStartOfWeek) ?? self
    }

    var fitPlannerShortWeekday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hant_TW")
        formatter.dateFormat = "E"
        return formatter.string(from: self)
    }

    var fitPlannerDayNumber: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hant_TW")
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }

    var fitPlannerMediumDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hant_TW")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter.string(from: self)
    }

    var fitPlannerShortDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hant_TW")
        formatter.dateFormat = "M/d"
        return formatter.string(from: self)
    }

    func addingFitPlannerDays(_ value: Int) -> Date {
        Calendar.fitPlanner.date(byAdding: .day, value: value, to: self) ?? self
    }

    func isSameFitPlannerDay(as otherDate: Date) -> Bool {
        Calendar.fitPlanner.isDate(self, inSameDayAs: otherDate)
    }

    func isInCurrentFitPlannerWeek(referenceDate: Date = Date()) -> Bool {
        self >= referenceDate.fitPlannerStartOfWeek && self < referenceDate.fitPlannerEndOfWeek
    }
}

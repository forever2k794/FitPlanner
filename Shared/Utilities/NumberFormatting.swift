import Foundation

enum NumberFormatting {
    static func weight(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(value.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 1))) + " kg"
    }

    static func volume(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0))) + " kg"
    }

    static func percentage(_ value: Double) -> String {
        value.formatted(.percent.precision(.fractionLength(0)))
    }
}

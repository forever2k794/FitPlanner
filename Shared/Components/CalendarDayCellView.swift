import SwiftUI

struct CalendarDayCellView: View {
    let day: CalendarDaySummary

    var body: some View {
        VStack(spacing: 6) {
            Text(day.date.fitPlannerDayNumber)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(dayNumberColor)
                .frame(width: 30, height: 30)
                .background(dayNumberBackground)
                .overlay(dayNumberBorder)

            HStack(spacing: 4) {
                if day.hasWorkoutRecord {
                    Circle()
                        .fill(.green)
                        .frame(width: 6, height: 6)
                }

                if day.hasPlannedWorkout {
                    Circle()
                        .fill(.blue)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(height: 8)
        }
        .frame(maxWidth: .infinity, minHeight: 54)
        .padding(.vertical, 8)
        .background(cellBackground)
        .opacity(day.isInDisplayedMonth ? 1 : 0.38)
    }

    private var dayNumberColor: Color {
        if day.isSelected {
            return .white
        }

        if day.isToday {
            return .blue
        }

        return .primary
    }

    @ViewBuilder
    private var dayNumberBackground: some View {
        if day.isSelected {
            Circle()
                .fill(.blue)
        } else {
            Circle()
                .fill(.clear)
        }
    }

    @ViewBuilder
    private var dayNumberBorder: some View {
        if day.isToday && !day.isSelected {
            Circle()
                .stroke(.blue, lineWidth: 1.5)
        }
    }

    private var cellBackground: some ShapeStyle {
        day.isSelected ? AnyShapeStyle(.blue.opacity(0.12)) : AnyShapeStyle(.thinMaterial)
    }
}

#Preview {
    CalendarDayCellView(
        day: CalendarDaySummary(
            date: Date(),
            isInDisplayedMonth: true,
            hasWorkoutRecord: true,
            workoutTitle: "全身訓練",
            totalVolume: 4200,
            completedSetCount: 12,
            hasPlannedWorkout: true,
            plannedTitle: "全身 A",
            plannedFocus: "全身",
            plannedExerciseCount: 4,
            isRestDay: false,
            isToday: true,
            isSelected: true
        )
    )
    .padding()
}

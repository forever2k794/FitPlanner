import SwiftUI

struct PlanCalendarView: View {
    @StateObject private var viewModel: PlanCalendarViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    private let weekdays = ["日", "一", "二", "三", "四", "五", "六"]

    init(viewModel: PlanCalendarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    calendarHeader
                    weekdayHeader
                    monthGrid
                    legend
                    selectedDateSection
                }
                .padding()
            }
            .navigationTitle("課表")
            .onAppear {
                viewModel.refresh()
            }
        }
    }

    private var calendarHeader: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.showPreviousMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("上一月")

            Spacer()

            Text(viewModel.monthTitle)
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                viewModel.showNextMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("下一月")
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 6) {
            ForEach(weekdays, id: \.self) { weekday in
                Text(weekday)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var monthGrid: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(viewModel.days) { day in
                Button {
                    viewModel.selectDate(day.date)
                } label: {
                    CalendarDayCellView(day: day)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var legend: some View {
        HStack(spacing: 14) {
            legendItem(color: .green, title: "訓練紀錄")
            legendItem(color: .blue, title: "建議課表")

            Spacer()
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private var selectedDateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: viewModel.selectedDateTitle,
                subtitle: "選取日期摘要"
            )

            if viewModel.selectedWorkoutRecords.isEmpty {
                EmptyStateView(
                    title: "這天沒有訓練紀錄",
                    message: "若有建議課表，會顯示在下方供你參考。",
                    systemImage: "calendar"
                )
            } else {
                ForEach(viewModel.selectedWorkoutRecords) { record in
                    WorkoutDaySummaryCardView(record: record)
                }
            }

            if let plannedWorkout = viewModel.selectedPlannedWorkout {
                plannedWorkoutCard(plannedWorkout)
            }
        }
    }

    private func plannedWorkoutCard(_ plannedWorkout: PlannedWorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: plannedWorkout.isRestDay ? "moon.zzz.fill" : "calendar.badge.clock")
                    .font(.title3)
                    .foregroundStyle(plannedWorkout.isRestDay ? .secondary : .blue)
                    .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text(plannedWorkout.title)
                        .font(.headline)

                    Text(plannedWorkout.isRestDay ? "休息日" : "\(plannedWorkout.focus) · \(plannedWorkout.plannedExercises.count) 個動作")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("建議")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.blue.opacity(0.12), in: Capsule())
                    .foregroundStyle(.blue)
            }

            if !plannedWorkout.plannedExercises.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(plannedWorkout.plannedExercises.prefix(4)) { plannedExercise in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(.blue.opacity(0.65))
                                .frame(width: 6, height: 6)

                            Text(plannedExercise.exercise.name)
                                .font(.subheadline)

                            Spacer()

                            Text("\(plannedExercise.targetSets) 組 x \(plannedExercise.targetReps) 次")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func legendItem(color: Color, title: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)

            Text(title)
        }
    }
}

#Preview {
    let container = AppContainer.preview()
    PlanCalendarView(
        viewModel: PlanCalendarViewModel(
            planGenerationService: container.planGenerationService,
            fitnessService: container.fitnessService
        )
    )
}

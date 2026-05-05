import SwiftUI

struct PlanCalendarView: View {
    @StateObject private var viewModel: PlanCalendarViewModel

    init(viewModel: PlanCalendarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeaderView(title: viewModel.planName, subtitle: viewModel.weekRangeTitle)

                    weekStrip
                    dayList
                }
                .padding()
            }
            .navigationTitle("課表")
            .onAppear {
                viewModel.refresh()
            }
        }
    }

    private var weekStrip: some View {
        HStack(spacing: 6) {
            ForEach(viewModel.days) { day in
                VStack(spacing: 6) {
                    Text(day.date.fitPlannerShortWeekday)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(day.date.fitPlannerDayNumber)
                        .font(.headline.weight(.semibold))
                        .frame(width: 32, height: 32)
                        .background(day.isToday ? Color.blue : Color.clear, in: Circle())
                        .foregroundStyle(day.isToday ? .white : .primary)

                    Circle()
                        .fill(statusColor(for: day.status))
                        .frame(width: 7, height: 7)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
    }

    private var dayList: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "本週安排")

            if viewModel.days.isEmpty {
                EmptyStateView(
                    title: "沒有課表資料",
                    message: "目前 repository 沒有產生可顯示的週課表。",
                    systemImage: "calendar.badge.exclamationmark"
                )
            } else {
                ForEach(viewModel.days) { day in
                    HStack(spacing: 12) {
                        VStack(spacing: 2) {
                            Text(day.date.fitPlannerShortWeekday)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(day.date.fitPlannerDayNumber)
                                .font(.title3.weight(.semibold))
                        }
                        .frame(width: 44)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(day.title)
                                .font(.headline)

                            Text(day.status == .rest ? "恢復與休息" : "\(day.focus) · \(day.exerciseCount) 個動作")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(day.status.rawValue)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(statusColor(for: day.status).opacity(0.14), in: Capsule())
                            .foregroundStyle(statusColor(for: day.status))
                    }
                    .padding(14)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
    }

    private func statusColor(for status: PlanCalendarDayStatus) -> Color {
        switch status {
        case .completed:
            return .green
        case .planned:
            return .blue
        case .rest:
            return .secondary
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

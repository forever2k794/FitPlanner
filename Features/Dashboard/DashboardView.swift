import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    init(viewModel: DashboardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        StatCardView(
                            title: "本週完成率",
                            value: NumberFormatting.percentage(viewModel.summary.weeklyCompletionRate),
                            subtitle: "依每週目標天數計算",
                            systemImage: "checkmark.circle.fill",
                            tint: .green
                        )

                        StatCardView(
                            title: "本週總訓練量",
                            value: NumberFormatting.volume(viewModel.summary.weeklyTotalVolume),
                            subtitle: "重量 x 次數",
                            systemImage: "scalemass.fill",
                            tint: .orange
                        )
                    }

                    nextWorkoutSection
                    latestWorkoutSection
                }
                .padding()
            }
            .navigationTitle("FitPlanner")
            .onAppear {
                viewModel.refresh()
            }
        }
    }

    @ViewBuilder
    private var nextWorkoutSection: some View {
        SectionHeaderView(title: "下一次訓練", subtitle: "由本地 mock 課表產生")

        if let nextWorkout = viewModel.summary.nextWorkout {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(nextWorkout.title)
                            .font(.title3.weight(.semibold))

                        Text(nextWorkout.date.fitPlannerMediumDate)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(nextWorkout.focus)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.blue.opacity(0.12), in: Capsule())
                        .foregroundStyle(.blue)
                }

                Text("\(nextWorkout.plannedExercises.count) 個動作")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            EmptyStateView(
                title: "沒有下一次訓練",
                message: "目前 mock 課表中沒有可顯示的下一次訓練。",
                systemImage: "calendar.badge.exclamationmark"
            )
        }
    }

    @ViewBuilder
    private var latestWorkoutSection: some View {
        SectionHeaderView(title: "最近一筆訓練", subtitle: "完成紀錄摘要")

        if let latestWorkout = viewModel.summary.latestWorkout {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(latestWorkout.title)
                            .font(.title3.weight(.semibold))

                        Text(latestWorkout.date.fitPlannerMediumDate)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                }

                Text("總訓練量 \(NumberFormatting.volume(latestWorkout.totalVolume))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(latestWorkout.muscleGroups.joined(separator: "、"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            EmptyStateView(
                title: "尚無訓練紀錄",
                message: "完成第一筆訓練後，這裡會顯示摘要。",
                systemImage: "list.bullet.clipboard"
            )
        }
    }
}

#Preview {
    let container = AppContainer.preview()
    DashboardView(
        viewModel: DashboardViewModel(
            progressSummaryService: container.progressSummaryService
        )
    )
}

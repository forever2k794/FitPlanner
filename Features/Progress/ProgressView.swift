import Charts
import SwiftUI

struct ProgressView: View {
    @StateObject private var viewModel: ProgressViewModel
    private let fitnessService: FitnessService

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    init(viewModel: ProgressViewModel, fitnessService: FitnessService) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.fitnessService = fitnessService
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeaderView(
                        title: "進度分析",
                        subtitle: "追蹤最近 8 週的訓練量、頻率與主要動作 PR"
                    )

                    summaryGrid
                    volumeTrendSection
                    workoutCountSection
                    personalRecordSection
                    muscleGroupSection
                    workoutHistoryLink
                }
                .padding()
            }
            .navigationTitle("進度")
            .onAppear {
                viewModel.refresh()
            }
        }
    }

    private var summaryGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            StatCardView(
                title: "總訓練次數",
                value: "\(viewModel.summary.totalWorkoutCount)",
                subtitle: "目前所有訓練紀錄",
                systemImage: "figure.strengthtraining.traditional",
                tint: .blue
            )

            StatCardView(
                title: "本週總容量",
                value: NumberFormatting.volume(viewModel.summary.weeklyTotalVolume),
                subtitle: "重量 x 次數",
                systemImage: "scalemass.fill",
                tint: .orange
            )

            StatCardView(
                title: "最近訓練",
                value: viewModel.summary.latestWorkoutDate?.fitPlannerShortDate ?? "尚無",
                subtitle: viewModel.summary.latestWorkoutDate?.fitPlannerShortWeekday,
                systemImage: "calendar.badge.clock",
                tint: .green
            )

            StatCardView(
                title: "最常訓練肌群",
                value: viewModel.summary.mostTrainedMuscleGroup,
                subtitle: "依動作出現次數統計",
                systemImage: "target",
                tint: .purple
            )
        }
    }

    private var volumeTrendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "最近 8 週訓練量",
                subtitle: "每週總容量，單位為 kg"
            )

            chartContainer {
                Chart(viewModel.weeklyMetrics) { metric in
                    LineMark(
                        x: .value("週", metric.label),
                        y: .value("總容量", metric.totalVolume)
                    )
                    .foregroundStyle(.orange)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("週", metric.label),
                        y: .value("總容量", metric.totalVolume)
                    )
                    .foregroundStyle(.orange)
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 190)
            }
        }
    }

    private var workoutCountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "最近 8 週訓練次數",
                subtitle: "每週完成的訓練紀錄數"
            )

            chartContainer {
                Chart(viewModel.weeklyMetrics) { metric in
                    BarMark(
                        x: .value("週", metric.label),
                        y: .value("次數", metric.workoutCount)
                    )
                    .foregroundStyle(.blue)
                    .cornerRadius(4)
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 170)
            }
        }
    }

    private var personalRecordSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "主要動作 PR",
                subtitle: "以已完成單組最大重量計算"
            )

            if viewModel.exercisePRs.isEmpty {
                EmptyStateView(
                    title: "尚無 PR 資料",
                    message: "完成主要動作訓練後，這裡會顯示你的最佳重量。",
                    systemImage: "trophy"
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.exercisePRs) { personalRecord in
                        personalRecordRow(personalRecord)

                        if personalRecord.id != viewModel.exercisePRs.last?.id {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
    }

    private var muscleGroupSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "常練肌群",
                subtitle: "依歷史紀錄中的動作出現次數排序"
            )

            if viewModel.muscleGroupFrequencies.isEmpty {
                EmptyStateView(
                    title: "尚無肌群統計",
                    message: "新增訓練紀錄後，這裡會顯示最常安排的肌群。",
                    systemImage: "chart.bar.xaxis"
                )
            } else {
                chartContainer {
                    Chart(viewModel.muscleGroupFrequencies) { metric in
                        BarMark(
                            x: .value("次數", metric.trainingCount),
                            y: .value("肌群", metric.muscleGroup)
                        )
                        .foregroundStyle(.purple)
                        .cornerRadius(4)
                    }
                    .chartXAxis {
                        AxisMarks(position: .bottom)
                    }
                    .frame(height: CGFloat(max(viewModel.muscleGroupFrequencies.count, 1)) * 38)
                }
            }
        }
    }

    private var workoutHistoryLink: some View {
        NavigationLink {
            WorkoutHistoryView(
                viewModel: WorkoutHistoryViewModel(
                    fitnessService: fitnessService
                )
            )
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text("查看過往訓練紀錄")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text("回顧每次訓練的動作、重量、次數與完成狀態")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func chartContainer<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(16)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func personalRecordRow(_ personalRecord: ExercisePRMetric) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "trophy.fill")
                .font(.headline)
                .foregroundStyle(.yellow)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(personalRecord.exerciseName)
                    .font(.headline)

                Text(personalRecord.date.fitPlannerShortDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(NumberFormatting.weight(personalRecord.weightInKilograms))
                    .font(.headline.weight(.semibold))

                Text("\(personalRecord.reps) 次")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
    }
}

#Preview {
    let container = AppContainer.preview()
    ProgressView(
        viewModel: ProgressViewModel(
            progressSummaryService: container.progressSummaryService,
            fitnessService: container.fitnessService
        ),
        fitnessService: container.fitnessService
    )
}

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
                        subtitle: "用頻率、PR、動作趨勢與推拉腿比例看訓練是否平衡"
                    )

                    summaryGrid
                    weeklyGoalSection
                    workoutCountSection
                    exerciseTrendSection
                    focusDistributionSection
                    personalRecordSection
                    trainingRecommendationSection
                    volumeTrendSection
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
                title: "本週完成",
                value: "\(viewModel.currentWeekWorkoutCount)/\(viewModel.weeklyTargetTrainingDays)",
                subtitle: "對照每週目標",
                systemImage: "calendar.badge.checkmark",
                tint: .green
            )

            StatCardView(
                title: "最近訓練",
                value: viewModel.summary.latestWorkoutDate?.fitPlannerShortDate ?? "尚無",
                subtitle: viewModel.summary.latestWorkoutDate?.fitPlannerShortWeekday,
                systemImage: "calendar.badge.clock",
                tint: .orange
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

    private var weeklyGoalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "本週目標進度",
                subtitle: "完成次數 / 每週目標訓練天數"
            )

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("已完成 \(viewModel.currentWeekWorkoutCount) 次")
                        .font(.headline)

                    Spacer()

                    Text("目標 \(viewModel.weeklyTargetTrainingDays) 次")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                SwiftUI.ProgressView(value: viewModel.weeklyTargetProgress)
                    .tint(.green)

                Text(viewModel.currentWeekWorkoutCount >= viewModel.weeklyTargetTrainingDays ? "本週已達標，接下來可以依恢復狀態安排訓練。" : "距離本週目標還差 \(max(viewModel.weeklyTargetTrainingDays - viewModel.currentWeekWorkoutCount, 0)) 次。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private var workoutCountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "最近 8 週訓練次數",
                subtitle: "每週完成的訓練紀錄數"
            )

            if viewModel.weeklyMetrics.allSatisfy({ $0.workoutCount == 0 }) {
                EmptyStateView(
                    title: "還沒有足夠紀錄產生趨勢",
                    message: "儲存幾次訓練後，這裡會顯示每週頻率變化。",
                    systemImage: "chart.bar"
                )
            } else {
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
    }

    private var exerciseTrendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                SectionHeaderView(
                    title: "動作進步趨勢",
                    subtitle: "查看最近幾次同一動作的最高重量與最高次數"
                )

                Spacer()

                if !viewModel.availableTrendExerciseNames.isEmpty {
                    Menu {
                        ForEach(viewModel.availableTrendExerciseNames, id: \.self) { exerciseName in
                            Button(exerciseName) {
                                viewModel.selectTrendExercise(exerciseName)
                            }
                        }
                    } label: {
                        Label(viewModel.selectedTrendExerciseName ?? "選擇動作", systemImage: "chevron.down")
                            .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                }
            }

            if viewModel.exerciseTrendMetrics.count < 2 {
                EmptyStateView(
                    title: "還沒有足夠紀錄產生趨勢",
                    message: "同一個動作至少需要兩次訓練紀錄，才能看出變化。",
                    systemImage: "point.3.connected.trianglepath.dotted"
                )
            } else {
                chartContainer {
                    VStack(alignment: .leading, spacing: 14) {
                        Chart(viewModel.exerciseTrendMetrics) { metric in
                            LineMark(
                                x: .value("日期", metric.label),
                                y: .value("最高重量", metric.maxWeightInKilograms)
                            )
                            .foregroundStyle(.green)
                            .interpolationMethod(.catmullRom)

                            PointMark(
                                x: .value("日期", metric.label),
                                y: .value("最高重量", metric.maxWeightInKilograms)
                            )
                            .foregroundStyle(.green)
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .frame(height: 170)

                        Divider()

                        VStack(alignment: .leading, spacing: 8) {
                            Text("最近最高次數")
                                .font(.subheadline.weight(.semibold))

                            ForEach(viewModel.exerciseTrendMetrics.suffix(4)) { metric in
                                HStack {
                                    Text(metric.label)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    Spacer()

                                    Text("\(metric.maxReps) 次")
                                        .font(.caption.weight(.semibold))
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var focusDistributionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "推拉腿與核心分布",
                subtitle: "依動作類型統計最近所有訓練紀錄"
            )

            if viewModel.focusDistributionMetrics.isEmpty {
                EmptyStateView(
                    title: "尚無分布資料",
                    message: "完成訓練後，這裡會顯示推、拉、腿與核心的比例。",
                    systemImage: "chart.pie"
                )
            } else {
                chartContainer {
                    VStack(spacing: 12) {
                        ForEach(viewModel.focusDistributionMetrics) { metric in
                            distributionBar(metric)
                        }
                    }
                }
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

    private var trainingRecommendationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "訓練建議",
                subtitle: "依目前頻率與推拉腿分布提供簡單提醒"
            )

            VStack(alignment: .leading, spacing: 10) {
                ForEach(viewModel.trainingRecommendations, id: \.self) { recommendation in
                    Label(recommendation, systemImage: "lightbulb.fill")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(16)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private var volumeTrendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "訓練容量參考",
                subtitle: "最近 8 週每週總容量，單位 kg"
            )

            if viewModel.weeklyMetrics.allSatisfy({ $0.totalVolume == 0 }) {
                EmptyStateView(
                    title: "尚無容量資料",
                    message: "儲存包含重量與次數的訓練後，這裡會顯示容量變化。",
                    systemImage: "scalemass"
                )
            } else {
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

    private func distributionBar(_ metric: TrainingFocusDistributionMetric) -> some View {
        let maxCount = max(viewModel.focusDistributionMetrics.map(\.trainingCount).max() ?? 1, 1)
        let progress = Double(metric.trainingCount) / Double(maxCount)

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(metric.focusName)
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Text("\(metric.trainingCount) 次")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.08))

                    Capsule()
                        .fill(focusColor(for: metric.focusName))
                        .frame(width: geometry.size.width * CGFloat(progress))
                }
            }
            .frame(height: 10)
        }
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

    private func focusColor(for focusName: String) -> Color {
        switch focusName {
        case "推":
            return .red
        case "拉":
            return .blue
        case "腿":
            return .green
        case "核心":
            return .purple
        default:
            return .secondary
        }
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

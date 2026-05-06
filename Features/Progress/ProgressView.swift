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
                    SectionHeaderView(title: "進度總覽", subtitle: "第一版先以本地紀錄做基礎統計")

                    LazyVGrid(columns: columns, spacing: 12) {
                        StatCardView(
                            title: "總訓練次數",
                            value: "\(viewModel.summary.totalWorkoutCount)",
                            subtitle: "歷史紀錄",
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
                            title: "最近訓練日期",
                            value: viewModel.summary.latestWorkoutDate?.fitPlannerShortDate ?? "無",
                            subtitle: viewModel.summary.latestWorkoutDate?.fitPlannerShortWeekday,
                            systemImage: "calendar.badge.clock",
                            tint: .green
                        )

                        StatCardView(
                            title: "最常訓練肌群",
                            value: viewModel.summary.mostTrainedMuscleGroup,
                            subtitle: "依動作出現次數",
                            systemImage: "target",
                            tint: .purple
                        )
                    }

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

                                Text("檢視每次訓練的動作、組數與重量")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
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
                .padding()
            }
            .navigationTitle("進度")
            .onAppear {
                viewModel.refresh()
            }
        }
    }
}

#Preview {
    let container = AppContainer.preview()
    ProgressView(
        viewModel: ProgressViewModel(
            progressSummaryService: container.progressSummaryService
        ),
        fitnessService: container.fitnessService
    )
}

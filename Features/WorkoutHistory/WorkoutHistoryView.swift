import SwiftUI

struct WorkoutHistoryView: View {
    @StateObject private var viewModel: WorkoutHistoryViewModel

    init(viewModel: WorkoutHistoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if viewModel.records.isEmpty {
                    EmptyStateView(
                        title: "尚無訓練紀錄",
                        message: "完成並儲存今日訓練後，這裡會顯示歷史紀錄。",
                        systemImage: "clock.badge.questionmark"
                    )
                } else {
                    ForEach(viewModel.records) { record in
                        NavigationLink {
                            WorkoutHistoryDetailView(record: record)
                        } label: {
                            WorkoutHistoryRecordRow(
                                record: record,
                                exerciseCount: viewModel.exerciseCount(for: record),
                                completedSetCount: viewModel.completedSetCount(for: record),
                                totalSetCount: viewModel.totalSetCount(for: record),
                                totalVolume: viewModel.totalVolume(for: record)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("訓練紀錄")
        .onAppear {
            viewModel.refresh()
        }
    }
}

private struct WorkoutHistoryRecordRow: View {
    let record: WorkoutSessionRecord
    let exerciseCount: Int
    let completedSetCount: Int
    let totalSetCount: Int
    let totalVolume: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(record.date.fitPlannerMediumDate)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }

            HStack(spacing: 8) {
                historyMetric(title: "動作", value: "\(exerciseCount)")
                historyMetric(title: "總量", value: NumberFormatting.volume(totalVolume))
                historyMetric(title: "完成", value: "\(completedSetCount)/\(totalSetCount)")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func historyMetric(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.background.opacity(0.65), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    let container = AppContainer.preview()
    NavigationStack {
        WorkoutHistoryView(
            viewModel: WorkoutHistoryViewModel(
                fitnessService: container.fitnessService
            )
        )
    }
}

import Foundation
import SwiftUI

struct WorkoutHistoryDetailView: View {
    @StateObject private var viewModel: WorkoutHistoryDetailViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: WorkoutHistoryDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private var record: WorkoutSessionRecord {
        viewModel.session
    }

    private var completedSetCount: Int {
        record.exerciseLogs.reduce(0) { count, exerciseLog in
            count + exerciseLog.sets.filter(\.isCompleted).count
        }
    }

    private var totalSetCount: Int {
        record.exerciseLogs.reduce(0) { count, exerciseLog in
            count + exerciseLog.sets.count
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                summarySection
                saveStatusSection
                editAvailabilitySection
                exerciseLogsSection
            }
            .padding()
        }
        .navigationTitle("紀錄詳情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if viewModel.canEdit {
                    NavigationLink {
                        WorkoutSessionEditView(
                            session: viewModel.session,
                            onSave: { updatedSession in
                                viewModel.save(updatedSession)
                            }
                        )
                    } label: {
                        Text("編輯")
                    }
                }

                if viewModel.canDelete {
                    Button(role: .destructive) {
                        if viewModel.deleteSession() {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("刪除訓練紀錄")
                }
            }
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(record.title)
                    .font(.largeTitle.weight(.bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text(record.date.fitPlannerMediumDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                detailMetric(title: "狀態", value: record.isCompleted ? "已完成" : "未完成")
                detailMetric(title: "總量", value: NumberFormatting.volume(record.totalVolume))
                detailMetric(title: "組數", value: "\(completedSetCount)/\(totalSetCount)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var saveStatusSection: some View {
        if let saveMessage = viewModel.saveMessage {
            Text(saveMessage)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(viewModel.didSaveSuccessfully ? .green : .orange)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background((viewModel.didSaveSuccessfully ? Color.green : Color.orange).opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    @ViewBuilder
    private var editAvailabilitySection: some View {
        if !viewModel.canEdit {
            Text("範例紀錄不可編輯")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private var exerciseLogsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(title: "動作明細", subtitle: "\(record.exerciseLogs.count) 個動作")

            if record.exerciseLogs.isEmpty {
                EmptyStateView(
                    title: "沒有動作紀錄",
                    message: "這筆訓練尚未包含任何動作資料。",
                    systemImage: "list.bullet.clipboard"
                )
            } else {
                ForEach(record.exerciseLogs) { exerciseLog in
                    exerciseLogCard(exerciseLog)
                }
            }
        }
    }

    private func exerciseLogCard(_ exerciseLog: ExerciseLog) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(exerciseLog.exercise.name)
                    .font(.headline)

                Text("\(exerciseLog.exercise.primaryMuscleGroup) · \(exerciseLog.exercise.equipment)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 8) {
                ForEach(exerciseLog.sets) { setLog in
                    setLogRow(setLog)
                }
            }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func setLogRow(_ setLog: SetLog) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("第 \(setLog.setNumber) 組")
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Label(setLog.isCompleted ? "完成" : "未完成", systemImage: setLog.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(setLog.isCompleted ? .green : .secondary)
            }

            HStack(spacing: 8) {
                detailMetric(title: "重量", value: NumberFormatting.weight(setLog.weightInKilograms))
                detailMetric(title: "次數", value: "\(setLog.reps)")
                detailMetric(title: "RPE", value: setLog.rpe.map { String(format: "%.1f", $0) } ?? "-")
                detailMetric(title: "RIR", value: setLog.rir.map(String.init) ?? "-")
            }
        }
        .padding(12)
        .background(.background.opacity(0.7), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func detailMetric(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.background.opacity(0.55), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    let container = AppContainer.preview()
    let record = container.fitnessService.workoutRecords().first!

    NavigationStack {
        WorkoutHistoryDetailView(
            viewModel: WorkoutHistoryDetailViewModel(
                session: record,
                fitnessService: container.fitnessService
            )
        )
    }
}

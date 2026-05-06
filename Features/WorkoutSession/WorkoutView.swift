import Foundation
import SwiftUI

struct WorkoutView: View {
    @StateObject private var viewModel: WorkoutViewModel
    @State private var expandedExerciseLogIDs: Set<UUID> = []

    init(viewModel: WorkoutViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    explanationSection
                    plannedExercisesSection
                    completionSection
                }
                .padding()
            }
            .navigationTitle("今日訓練")
            .onAppear {
                viewModel.refresh()
                expandFirstDraftIfNeeded()
            }
        }
    }

    @ViewBuilder
    private var headerSection: some View {
        if let plannedWorkoutDay = viewModel.plannedWorkoutDay {
            VStack(alignment: .leading, spacing: 8) {
                Text(plannedWorkoutDay.date.fitPlannerMediumDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(plannedWorkoutDay.title)
                    .font(.largeTitle.weight(.bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text(plannedWorkoutDay.focus)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.blue)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            SectionHeaderView(title: "今日課表", subtitle: Date().fitPlannerMediumDate)
        }
    }

    @ViewBuilder
    private var explanationSection: some View {
        if let explanation = viewModel.planGenerationExplanation {
            DisclosureGroup {
                VStack(alignment: .leading, spacing: 14) {
                    explanationText(explanation.summary)
                    explanationText(explanation.splitReason)
                    explanationText(explanation.historyReference)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("動作調整")
                            .font(.subheadline.weight(.semibold))

                        ForEach(explanation.exerciseReasons) { reason in
                            HStack(alignment: .top, spacing: 10) {
                                Text(reason.adjustment.displayName)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(adjustmentColor(for: reason.adjustment))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(adjustmentColor(for: reason.adjustment).opacity(0.12), in: Capsule())

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(reason.exerciseName)
                                        .font(.subheadline.weight(.semibold))

                                    Text(reason.reason)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 10)
            } label: {
                Label("為什麼安排這份課表？", systemImage: "lightbulb.fill")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            .padding(16)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private func explanationText(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func adjustmentColor(for adjustment: PlanAdjustmentType) -> Color {
        switch adjustment {
        case .progressed:
            return .green
        case .maintained:
            return .blue
        case .reduced:
            return .orange
        case .defaulted:
            return .secondary
        }
    }

    @ViewBuilder
    private var plannedExercisesSection: some View {
        if !viewModel.exerciseLogDrafts.isEmpty {
            SectionHeaderView(title: "動作紀錄", subtitle: "展開動作後編輯每一組資料")

            VStack(spacing: 14) {
                ForEach(viewModel.exerciseLogDrafts) { exerciseLog in
                    VStack(spacing: 10) {
                        Button {
                            toggleExerciseLog(exerciseLog.id)
                        } label: {
                            WorkoutExerciseSummaryRow(
                                exerciseLog: exerciseLog,
                                plannedExercise: viewModel.plannedExercise(for: exerciseLog.exercise.id),
                                isExpanded: expandedExerciseLogIDs.contains(exerciseLog.id)
                            )
                        }
                        .buttonStyle(.plain)

                        if expandedExerciseLogIDs.contains(exerciseLog.id) {
                            ExerciseLogEditorView(
                                exerciseLog: exerciseLog,
                                plannedExercise: viewModel.plannedExercise(for: exerciseLog.exercise.id),
                                onAddSet: {
                                    viewModel.addSet(to: exerciseLog.id)
                                },
                                onDeleteSet: { setID in
                                    viewModel.deleteSet(setID, from: exerciseLog.id)
                                },
                                onUpdateSet: { updatedSet in
                                    viewModel.updateSet(updatedSet, in: exerciseLog.id)
                                }
                            )
                        }
                    }
                }
            }
        } else {
            EmptyStateView(
                title: "今天是休息日",
                message: "目前 mock 課表沒有安排訓練，建議保留恢復與活動度練習。",
                systemImage: "moon.zzz.fill"
            )
        }
    }

    @ViewBuilder
    private var completionSection: some View {
        if let message = viewModel.completionMessage {
            Text(message)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(viewModel.hasCompletedToday ? .green : .secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(.green.opacity(viewModel.hasCompletedToday ? 0.12 : 0.05), in: RoundedRectangle(cornerRadius: 8))
        }

        Button {
            viewModel.saveWorkoutSession()
        } label: {
            Label(viewModel.hasCompletedToday ? "今日訓練已儲存" : "儲存今日訓練", systemImage: "square.and.arrow.down.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(!viewModel.canSaveWorkoutSession)
    }

    private func toggleExerciseLog(_ id: UUID) {
        if expandedExerciseLogIDs.contains(id) {
            expandedExerciseLogIDs.remove(id)
        } else {
            expandedExerciseLogIDs.insert(id)
        }
    }

    private func expandFirstDraftIfNeeded() {
        guard expandedExerciseLogIDs.isEmpty, let firstExerciseLogID = viewModel.exerciseLogDrafts.first?.id else {
            return
        }

        expandedExerciseLogIDs.insert(firstExerciseLogID)
    }
}

private struct WorkoutExerciseSummaryRow: View {
    let exerciseLog: ExerciseLog
    let plannedExercise: PlannedExercise?
    let isExpanded: Bool

    private var completedSetCount: Int {
        exerciseLog.sets.filter(\.isCompleted).count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exerciseLog.exercise.name)
                        .font(.headline)

                    Text("\(exerciseLog.exercise.primaryMuscleGroup) · \(exerciseLog.exercise.equipment)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                    .foregroundStyle(.blue)
                    .font(.title3)
            }

            HStack(spacing: 8) {
                metricPill(title: "已輸入", value: "\(exerciseLog.sets.count) 組")
                metricPill(title: "已完成", value: "\(completedSetCount) 組")
                metricPill(title: "總量", value: NumberFormatting.volume(exerciseLog.totalVolume))
            }

            if let plannedExercise {
                Text("建議 \(plannedExercise.targetSets) 組 x \(plannedExercise.targetReps) 次 · \(NumberFormatting.weight(plannedExercise.suggestedWeightInKilograms))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func metricPill(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline.weight(.semibold))
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
    WorkoutView(
        viewModel: WorkoutViewModel(
            fitnessService: container.fitnessService,
            planGenerationService: container.planGenerationService
        )
    )
}

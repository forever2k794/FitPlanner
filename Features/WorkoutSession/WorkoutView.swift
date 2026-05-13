import Foundation
import SwiftUI

struct WorkoutView: View {
    @StateObject private var viewModel: WorkoutViewModel
    @State private var expandedExerciseLogIDs: Set<UUID> = []
    @State private var isShowingAddExercise = false

    init(viewModel: WorkoutViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    workoutPreferenceSection
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
            .sheet(isPresented: $isShowingAddExercise) {
                AddExerciseToWorkoutView(
                    exercises: viewModel.availableExercises,
                    onSelect: { exercise in
                        viewModel.addExercise(exercise)
                        if let lastExerciseLogID = viewModel.exerciseLogDrafts.last?.id {
                            expandedExerciseLogIDs.insert(lastExerciseLogID)
                        }
                    }
                )
            }
        }
    }

    private var workoutPreferenceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(
                title: "今天想練什麼？",
                subtitle: "先選目標、器材與訓練方式，再重新產生課表"
            )

            HStack(spacing: 10) {
                preferenceMenu(
                    title: "訓練類型",
                    value: viewModel.selectedFocusType.displayName
                ) {
                    ForEach(viewModel.availableFocusTypes) { focusType in
                        Button(focusType.displayName) {
                            viewModel.selectFocusType(focusType)
                        }
                    }
                }

                preferenceMenu(
                    title: "訓練方式",
                    value: viewModel.selectedTrainingStyle.displayName
                ) {
                    ForEach(viewModel.availableTrainingStyles) { trainingStyle in
                        Button(trainingStyle.displayName) {
                            viewModel.selectTrainingStyle(trainingStyle)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("可用器材")
                    .font(.subheadline.weight(.semibold))

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(viewModel.availableEquipmentTypes) { equipmentType in
                        Button {
                            viewModel.toggleEquipmentType(equipmentType)
                        } label: {
                            Label(
                                equipmentType.displayName,
                                systemImage: viewModel.isEquipmentSelected(equipmentType) ? "checkmark.circle.fill" : "circle"
                            )
                            .font(.caption.weight(.medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(viewModel.isEquipmentSelected(equipmentType) ? .blue : .secondary)
                    }
                }
            }

            Button {
                viewModel.regenerateWorkout()
                expandedExerciseLogIDs = Set(viewModel.exerciseLogDrafts.prefix(1).map(\.id))
            } label: {
                Label("重新產生課表", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    @ViewBuilder
    private var headerSection: some View {
        if let plannedWorkoutDay = viewModel.plannedWorkoutDay {
            VStack(alignment: .leading, spacing: 8) {
                Text("下一次建議課表")
                    .font(.headline)

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

    private func preferenceMenu<Content: View>(
        title: String,
        value: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        Menu {
            content()
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack {
                    Text(value)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background.opacity(0.65), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
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
            HStack(alignment: .top, spacing: 12) {
                SectionHeaderView(title: "動作紀錄", subtitle: "展開動作後編輯每一組資料")

                Button {
                    isShowingAddExercise = true
                } label: {
                    Label("新增動作", systemImage: "plus.circle.fill")
                        .labelStyle(.iconOnly)
                        .font(.title3)
                }
                .accessibilityLabel("新增動作")
            }

            VStack(spacing: 14) {
                ForEach(viewModel.exerciseLogDrafts) { exerciseLog in
                    VStack(spacing: 10) {
                        WorkoutExerciseSummaryRow(
                            exerciseLog: exerciseLog,
                            plannedExercise: viewModel.plannedExercise(for: exerciseLog.exercise.id),
                            isExpanded: expandedExerciseLogIDs.contains(exerciseLog.id),
                            onToggle: {
                                toggleExerciseLog(exerciseLog.id)
                            },
                            onRemove: {
                                viewModel.removeExerciseLog(exerciseLog.id)
                                expandedExerciseLogIDs.remove(exerciseLog.id)
                            }
                        )

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
            VStack(spacing: 12) {
                EmptyStateView(
                    title: "目前沒有動作",
                    message: "可以重新產生課表，或手動新增今天想練的動作。",
                    systemImage: "plus.circle"
                )

                Button {
                    isShowingAddExercise = true
                } label: {
                    Label("新增動作", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    @ViewBuilder
    private var completionSection: some View {
        if let message = viewModel.completionMessage {
            Text(message)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(feedbackColor(for: viewModel.completionMessageStyle))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(feedbackColor(for: viewModel.completionMessageStyle).opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
        }

        Button {
            viewModel.saveWorkoutSession()
        } label: {
            Label(viewModel.hasCompletedToday ? "本次訓練已儲存" : "儲存本次訓練", systemImage: "square.and.arrow.down.fill")
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

    private func feedbackColor(for style: WorkoutFeedbackStyle) -> Color {
        switch style {
        case .success:
            return .green
        case .warning:
            return .orange
        case .info:
            return .secondary
        }
    }
}

private struct WorkoutExerciseSummaryRow: View {
    let exerciseLog: ExerciseLog
    let plannedExercise: PlannedExercise?
    let isExpanded: Bool
    let onToggle: () -> Void
    let onRemove: () -> Void

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

                Button(role: .destructive) {
                    onRemove()
                } label: {
                    Image(systemName: "trash")
                        .font(.headline)
                }
                .accessibilityLabel("移除此動作")

                Button {
                    onToggle()
                } label: {
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.title3)
                }
                .accessibilityLabel(isExpanded ? "收合動作" : "展開動作")
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
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
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

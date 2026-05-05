import SwiftUI

struct WorkoutView: View {
    @StateObject private var viewModel: WorkoutViewModel

    init(viewModel: WorkoutViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    plannedExercisesSection
                    completionSection
                }
                .padding()
            }
            .navigationTitle("今日訓練")
            .onAppear {
                viewModel.refresh()
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
    private var plannedExercisesSection: some View {
        if let plannedWorkoutDay = viewModel.plannedWorkoutDay, !plannedWorkoutDay.plannedExercises.isEmpty {
            SectionHeaderView(title: "動作清單", subtitle: "建議重量、次數與強度")

            VStack(spacing: 12) {
                ForEach(plannedWorkoutDay.plannedExercises) { plannedExercise in
                    PlannedExerciseRowView(plannedExercise: plannedExercise)
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
            viewModel.completeTodayWorkout()
        } label: {
            Label(viewModel.hasCompletedToday ? "今日訓練已完成" : "完成今日訓練", systemImage: "checkmark.circle.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(viewModel.hasCompletedToday || viewModel.plannedWorkoutDay?.isRestDay != false)
    }
}

private struct PlannedExerciseRowView: View {
    let plannedExercise: PlannedExercise

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plannedExercise.exercise.name)
                        .font(.headline)

                    Text("\(plannedExercise.exercise.primaryMuscleGroup) · \(plannedExercise.exercise.equipment)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(NumberFormatting.weight(plannedExercise.suggestedWeightInKilograms))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
            }

            HStack(spacing: 8) {
                metricPill(title: "組數", value: "\(plannedExercise.targetSets)")
                metricPill(title: "次數", value: "\(plannedExercise.targetReps)")
                metricPill(title: "RPE", value: plannedExercise.targetRPE.map { String(format: "%.1f", $0) } ?? "-")
                metricPill(title: "RIR", value: plannedExercise.targetRIR.map(String.init) ?? "-")
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
            fitnessService: container.fitnessService
        )
    )
}

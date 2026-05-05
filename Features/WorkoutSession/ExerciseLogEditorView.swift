import Foundation
import SwiftUI

struct ExerciseLogEditorView: View {
    let exerciseLog: ExerciseLog
    let plannedExercise: PlannedExercise?
    let onAddSet: () -> Void
    let onDeleteSet: (UUID) -> Void
    let onUpdateSet: (SetLog) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(exerciseLog.exercise.name)
                    .font(.title3.weight(.semibold))

                Text(exerciseLog.exercise.note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let plannedExercise {
                Text("建議 \(plannedExercise.targetSets) 組 x \(plannedExercise.targetReps) 次 · \(NumberFormatting.weight(plannedExercise.suggestedWeightInKilograms))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if exerciseLog.sets.isEmpty {
                EmptyStateView(
                    title: "尚未建立組數",
                    message: "點擊新增一組後，就可以輸入重量、次數與強度。",
                    systemImage: "plus.circle"
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(exerciseLog.sets) { setLog in
                        VStack(alignment: .trailing, spacing: 8) {
                            SetLogRowView(setLog: setLog, onUpdate: onUpdateSet)

                            Button(role: .destructive) {
                                onDeleteSet(setLog.id)
                            } label: {
                                Label("刪除此組", systemImage: "trash")
                            }
                            .font(.caption)
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }

            Button {
                onAddSet()
            } label: {
                Label("新增一組", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    let exercise = MockExercises.exercise(named: "臥推")
    let plannedExercise = PlannedExercise(
        exercise: exercise,
        targetSets: 4,
        targetReps: 6,
        suggestedWeightInKilograms: 72.5,
        targetRPE: 8,
        targetRIR: 2
    )
    let exerciseLog = ExerciseLog(
        exercise: exercise,
        sets: [
            SetLog(setNumber: 1, weightInKilograms: 72.5, reps: 6, rpe: 8, rir: 2),
            SetLog(setNumber: 2, weightInKilograms: 72.5, reps: 6, rpe: 8, rir: 2)
        ]
    )

    ExerciseLogEditorView(
        exerciseLog: exerciseLog,
        plannedExercise: plannedExercise,
        onAddSet: {},
        onDeleteSet: { _ in },
        onUpdateSet: { _ in }
    )
    .padding()
}

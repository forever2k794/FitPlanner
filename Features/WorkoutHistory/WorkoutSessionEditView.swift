import Foundation
import SwiftUI

struct WorkoutSessionEditView: View {
    let onSave: (WorkoutSessionRecord) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draftSession: WorkoutSessionRecord

    init(
        session: WorkoutSessionRecord,
        onSave: @escaping (WorkoutSessionRecord) -> Void
    ) {
        self.onSave = onSave
        _draftSession = State(initialValue: session)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("訓練標題")
                        .font(.headline)

                    TextField("訓練標題", text: $draftSession.title)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 14) {
                    SectionHeaderView(title: "動作與組數", subtitle: "修改每一組的重量、次數與強度")

                    if draftSession.exerciseLogs.isEmpty {
                        EmptyStateView(
                            title: "沒有動作紀錄",
                            message: "這筆訓練目前沒有可編輯的動作資料。",
                            systemImage: "list.bullet.clipboard"
                        )
                    } else {
                        ForEach(draftSession.exerciseLogs) { exerciseLog in
                            ExerciseLogEditorView(
                                exerciseLog: exerciseLog,
                                plannedExercise: nil,
                                onAddSet: {
                                    addSet(to: exerciseLog.id)
                                },
                                onDeleteSet: { setID in
                                    deleteSet(setID, from: exerciseLog.id)
                                },
                                onUpdateSet: { updatedSet in
                                    updateSet(updatedSet, in: exerciseLog.id)
                                }
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("編輯訓練紀錄")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("儲存") {
                    onSave(draftSession)
                    dismiss()
                }
                .disabled(
                    draftSession.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    draftSession.exerciseLogs.isEmpty
                )
            }
        }
    }

    private func addSet(to exerciseLogID: UUID) {
        guard let exerciseLogIndex = draftSession.exerciseLogs.firstIndex(where: { $0.id == exerciseLogID }) else {
            return
        }

        let existingSets = draftSession.exerciseLogs[exerciseLogIndex].sets
        let previousSet = existingSets.last
        let nextSet = SetLog(
            setNumber: existingSets.count + 1,
            weightInKilograms: previousSet?.weightInKilograms ?? 0,
            reps: previousSet?.reps ?? 8,
            rpe: previousSet?.rpe ?? 8,
            rir: previousSet?.rir ?? 2,
            isCompleted: false
        )

        draftSession.exerciseLogs[exerciseLogIndex].sets.append(nextSet)
        normalizeSetNumbers(for: exerciseLogIndex)
    }

    private func deleteSet(_ setID: UUID, from exerciseLogID: UUID) {
        guard let exerciseLogIndex = draftSession.exerciseLogs.firstIndex(where: { $0.id == exerciseLogID }) else {
            return
        }

        draftSession.exerciseLogs[exerciseLogIndex].sets.removeAll { $0.id == setID }
        normalizeSetNumbers(for: exerciseLogIndex)
    }

    private func updateSet(_ updatedSet: SetLog, in exerciseLogID: UUID) {
        guard
            let exerciseLogIndex = draftSession.exerciseLogs.firstIndex(where: { $0.id == exerciseLogID }),
            let setIndex = draftSession.exerciseLogs[exerciseLogIndex].sets.firstIndex(where: { $0.id == updatedSet.id })
        else {
            return
        }

        draftSession.exerciseLogs[exerciseLogIndex].sets[setIndex] = updatedSet
    }

    private func normalizeSetNumbers(for exerciseLogIndex: Int) {
        draftSession.exerciseLogs[exerciseLogIndex].sets = draftSession.exerciseLogs[exerciseLogIndex].sets.enumerated().map { index, setLog in
            SetLog(
                id: setLog.id,
                setNumber: index + 1,
                weightInKilograms: setLog.weightInKilograms,
                reps: setLog.reps,
                rpe: setLog.rpe,
                rir: setLog.rir,
                isCompleted: setLog.isCompleted
            )
        }
    }
}

#Preview {
    let container = AppContainer.preview()
    let session = container.fitnessService.workoutRecords().first!

    NavigationStack {
        WorkoutSessionEditView(
            session: session,
            onSave: { _ in }
        )
    }
}

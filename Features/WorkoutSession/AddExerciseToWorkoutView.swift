import SwiftUI

struct AddExerciseToWorkoutView: View {
    let exercises: [Exercise]
    let onSelect: (Exercise) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredExercises: [Exercise] {
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            return exercises
        }

        return exercises.filter { exercise in
            exercise.name.localizedCaseInsensitiveContains(trimmedText) ||
            exercise.primaryMuscleGroup.localizedCaseInsensitiveContains(trimmedText) ||
            exercise.equipment.localizedCaseInsensitiveContains(trimmedText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if filteredExercises.isEmpty {
                    EmptyStateView(
                        title: "找不到動作",
                        message: "請嘗試輸入其他動作名稱、肌群或器材。",
                        systemImage: "magnifyingglass"
                    )
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(filteredExercises) { exercise in
                        Button {
                            onSelect(exercise)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(exercise.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                Text("\(exercise.primaryMuscleGroup) · \(exercise.equipment)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Text("預設 \(exercise.defaultSets) 組 x \(exercise.defaultReps) 次")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("新增動作")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "搜尋動作、肌群或器材")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddExerciseToWorkoutView(
        exercises: MockExercises.all,
        onSelect: { _ in }
    )
}

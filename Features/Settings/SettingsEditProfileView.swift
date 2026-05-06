import Foundation
import SwiftUI

struct SettingsEditProfileView: View {
    let profile: UserProfile
    let onSave: (UserProfile) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var heightText: String
    @State private var weightText: String
    @State private var goal: String
    @State private var experienceLevel: String
    @State private var weeklyTargetTrainingDays: Int

    private let experienceLevels = ["新手", "初階", "中階", "進階"]

    init(
        profile: UserProfile,
        onSave: @escaping (UserProfile) -> Void
    ) {
        self.profile = profile
        self.onSave = onSave
        _name = State(initialValue: profile.name)
        _heightText = State(initialValue: Self.formattedDecimal(profile.heightInCentimeters))
        _weightText = State(initialValue: Self.formattedDecimal(profile.weightInKilograms))
        _goal = State(initialValue: profile.goal)
        _experienceLevel = State(initialValue: profile.experienceLevel)
        _weeklyTargetTrainingDays = State(initialValue: profile.weeklyTargetTrainingDays)
    }

    var body: some View {
        Form {
            Section("基本資料") {
                TextField("名稱", text: $name)

                TextField("身高 cm", text: $heightText)
                    .keyboardType(.decimalPad)

                TextField("體重 kg", text: $weightText)
                    .keyboardType(.decimalPad)
            }

            Section("訓練目標") {
                TextField("目標", text: $goal)

                Picker("經驗程度", selection: $experienceLevel) {
                    ForEach(experienceLevels, id: \.self) { level in
                        Text(level).tag(level)
                    }
                }

                Stepper(value: $weeklyTargetTrainingDays, in: 1...7) {
                    HStack {
                        Text("每週目標訓練天數")
                        Spacer()
                        Text("\(weeklyTargetTrainingDays) 天")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("編輯個人資料")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("儲存") {
                    onSave(updatedProfile())
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func updatedProfile() -> UserProfile {
        UserProfile(
            id: profile.id,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            heightInCentimeters: parsedDecimal(from: heightText, fallback: profile.heightInCentimeters),
            weightInKilograms: parsedDecimal(from: weightText, fallback: profile.weightInKilograms),
            goal: goal.trimmingCharacters(in: .whitespacesAndNewlines),
            experienceLevel: experienceLevel,
            weeklyTargetTrainingDays: weeklyTargetTrainingDays
        )
    }

    private func parsedDecimal(from text: String, fallback: Double) -> Double {
        let normalizedText = text.replacingOccurrences(of: ",", with: ".")
        return max(Double(normalizedText) ?? fallback, 0)
    }

    private static func formattedDecimal(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        }

        return String(format: "%.1f", value)
    }
}

#Preview {
    NavigationStack {
        SettingsEditProfileView(
            profile: MockUserProfile.current,
            onSave: { _ in }
        )
    }
}

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("使用者資料") {
                    settingsRow(title: "名稱", value: viewModel.userProfile.name)
                    settingsRow(title: "身高", value: NumberFormatting.weight(viewModel.userProfile.heightInCentimeters).replacingOccurrences(of: "kg", with: "cm"))
                    settingsRow(title: "體重", value: NumberFormatting.weight(viewModel.userProfile.weightInKilograms))
                    settingsRow(title: "目標", value: viewModel.userProfile.goal)
                    settingsRow(title: "經驗程度", value: viewModel.userProfile.experienceLevel)
                    settingsRow(title: "每週目標訓練天數", value: "\(viewModel.userProfile.weeklyTargetTrainingDays) 天")
                }
            }
            .navigationTitle("設定")
            .onAppear {
                viewModel.refresh()
            }
        }
    }

    private func settingsRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    let container = AppContainer.preview()
    SettingsView(
        viewModel: SettingsViewModel(
            fitnessService: container.fitnessService
        )
    )
}

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

                Section("資料管理") {
                    NavigationLink {
                        SettingsEditProfileView(
                            profile: viewModel.userProfile,
                            onSave: { updatedProfile in
                                viewModel.saveUserProfile(updatedProfile)
                            }
                        )
                    } label: {
                        Label("編輯個人資料", systemImage: "person.crop.circle.badge.pencil")
                    }

                    Button {
                        viewModel.prepareBackupExport()
                    } label: {
                        Label("準備匯出備份", systemImage: "doc.badge.gearshape")
                    }

                    if let backupFileURL = viewModel.backupFileURL {
                        ShareLink(item: backupFileURL) {
                            Label("分享備份檔", systemImage: "square.and.arrow.up")
                        }
                    }

                    if let exportErrorMessage = viewModel.exportErrorMessage {
                        Text(exportErrorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
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
            fitnessService: container.fitnessService,
            backupExportService: container.backupExportService
        )
    )
}

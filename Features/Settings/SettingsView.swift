import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @State private var isShowingBackupImporter = false

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

                    if let profileStatusMessage = viewModel.profileStatusMessage {
                        statusText(profileStatusMessage, color: .green)
                    }
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
                        Label("準備匯出 JSON 備份", systemImage: "doc.badge.gearshape")
                    }

                    if let backupFileURL = viewModel.backupFileURL {
                        ShareLink(item: backupFileURL) {
                            Label("分享備份檔", systemImage: "square.and.arrow.up")
                        }
                    } else {
                        Text("尚未產生可分享的備份檔。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        isShowingBackupImporter = true
                    } label: {
                        Label("匯入 JSON 備份", systemImage: "tray.and.arrow.down")
                    }

                    if let exportSuccessMessage = viewModel.exportSuccessMessage {
                        statusText(exportSuccessMessage, color: .green)
                    }

                    if let exportErrorMessage = viewModel.exportErrorMessage {
                        statusText(exportErrorMessage, color: .red)
                    }

                    if let importSuccessMessage = viewModel.importSuccessMessage {
                        statusText(importSuccessMessage, color: .green)
                    }

                    if let importErrorMessage = viewModel.importErrorMessage {
                        statusText(importErrorMessage, color: .red)
                    }
                }
            }
            .navigationTitle("設定")
            .onAppear {
                viewModel.refresh()
            }
            .fileImporter(
                isPresented: $isShowingBackupImporter,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else {
                        viewModel.markBackupImportFailed()
                        return
                    }

                    viewModel.importBackup(from: url)
                case .failure:
                    viewModel.markBackupImportFailed()
                }
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

    private func statusText(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(color)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    let container = AppContainer.preview()
    SettingsView(
        viewModel: SettingsViewModel(
            fitnessService: container.fitnessService,
            backupExportService: container.backupExportService,
            backupImportService: container.backupImportService
        )
    )
}

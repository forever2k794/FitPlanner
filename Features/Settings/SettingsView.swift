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
                personalProfileSection
                trainingPreferenceSection
                dataManagementSection
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

    private var personalProfileSection: some View {
        Section {
            settingsRow(title: "名稱", value: viewModel.userProfile.name)
            settingsRow(title: "身高", value: NumberFormatting.weight(viewModel.userProfile.heightInCentimeters).replacingOccurrences(of: "kg", with: "cm"))
            settingsRow(title: "體重", value: NumberFormatting.weight(viewModel.userProfile.weightInKilograms))
            settingsRow(title: "目標", value: viewModel.userProfile.goal)
            settingsRow(title: "經驗程度", value: viewModel.userProfile.experienceLevel)
            settingsRow(title: "每週目標訓練天數", value: "\(viewModel.userProfile.weeklyTargetTrainingDays) 天")

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

            if let profileStatusMessage = viewModel.profileStatusMessage {
                statusText(profileStatusMessage, color: .green)
            }
        } header: {
            Text("個人資料")
        } footer: {
            Text("這些資料會影響 Dashboard 統計與課表建議。")
        }
    }

    private var trainingPreferenceSection: some View {
        Section {
            infoRow(
                title: "目前訓練方向",
                value: viewModel.userProfile.goal,
                systemImage: "target"
            )
            infoRow(
                title: "建議週頻率",
                value: "\(viewModel.userProfile.weeklyTargetTrainingDays) 天 / 週",
                systemImage: "calendar.badge.checkmark"
            )
            infoRow(
                title: "今日課表偏好",
                value: "可在今日訓練頁選擇推、拉、腿、全身、器材與訓練方式。",
                systemImage: "slider.horizontal.3"
            )
            infoRow(
                title: "適合族群方向",
                value: "新手可先用全身訓練；增肌、力量或時間較少時，可依當天狀態切換課表生成條件。",
                systemImage: "figure.strengthtraining.traditional"
            )
        } header: {
            Text("訓練偏好")
        } footer: {
            Text("v0.1.2 先顯示目前可用偏好，不新增保存欄位，避免修改資料格式。")
        }
    }

    private var dataManagementSection: some View {
        Section {
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
        } header: {
            Text("資料管理")
        } footer: {
            Text("匯出會建立可分享的 JSON 備份檔；匯入只接受 FitPlanner v1 備份格式。")
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

    private func infoRow(title: String, value: String, systemImage: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(.blue)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))

                Text(value)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 2)
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

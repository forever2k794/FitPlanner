import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published private(set) var userProfile: UserProfile
    @Published private(set) var backupFileURL: URL?
    @Published private(set) var profileStatusMessage: String?
    @Published private(set) var exportSuccessMessage: String?
    @Published private(set) var exportErrorMessage: String?
    @Published private(set) var importSuccessMessage: String?
    @Published private(set) var importErrorMessage: String?

    private let fitnessService: FitnessService
    private let backupExportService: BackupExportService
    private let backupImportService: BackupImportService

    init(
        fitnessService: FitnessService,
        backupExportService: BackupExportService,
        backupImportService: BackupImportService
    ) {
        self.fitnessService = fitnessService
        self.backupExportService = backupExportService
        self.backupImportService = backupImportService
        self.userProfile = fitnessService.userProfile()
    }

    func refresh() {
        userProfile = fitnessService.userProfile()
    }

    func saveUserProfile(_ profile: UserProfile) {
        fitnessService.saveUserProfile(profile)
        profileStatusMessage = "個人資料已儲存。"
        refresh()
    }

    func prepareBackupExport() {
        do {
            backupFileURL = try backupExportService.exportBackup()
            exportSuccessMessage = "備份檔已準備好，可以分享或儲存。"
            exportErrorMessage = nil
        } catch {
            backupFileURL = nil
            exportSuccessMessage = nil
            exportErrorMessage = "備份檔產生失敗，請稍後再試。"
        }
    }

    func importBackup(from url: URL) {
        do {
            try backupImportService.importBackup(from: url)
            importSuccessMessage = "備份匯入成功，資料已更新。"
            importErrorMessage = nil
            profileStatusMessage = nil
            refresh()
        } catch {
            importSuccessMessage = nil
            importErrorMessage = error.localizedDescription
        }
    }

    func markBackupImportFailed() {
        importSuccessMessage = nil
        importErrorMessage = "無法選擇備份檔，請再試一次。"
    }
}

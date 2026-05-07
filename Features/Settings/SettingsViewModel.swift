import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published private(set) var userProfile: UserProfile
    @Published private(set) var backupFileURL: URL?
    @Published private(set) var exportErrorMessage: String?

    private let fitnessService: FitnessService
    private let backupExportService: BackupExportService

    init(
        fitnessService: FitnessService,
        backupExportService: BackupExportService
    ) {
        self.fitnessService = fitnessService
        self.backupExportService = backupExportService
        self.userProfile = fitnessService.userProfile()
    }

    func refresh() {
        userProfile = fitnessService.userProfile()
    }

    func saveUserProfile(_ profile: UserProfile) {
        fitnessService.saveUserProfile(profile)
        refresh()
    }

    func prepareBackupExport() {
        do {
            backupFileURL = try backupExportService.exportBackup()
            exportErrorMessage = nil
        } catch {
            backupFileURL = nil
            exportErrorMessage = "備份檔產生失敗，請稍後再試。"
        }
    }
}

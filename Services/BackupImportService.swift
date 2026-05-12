import Foundation

enum BackupImportError: LocalizedError {
    case unreadableFile
    case invalidBackupFile
    case unsupportedSchemaVersion(Int)

    var errorDescription: String? {
        switch self {
        case .unreadableFile:
            return "無法讀取備份檔，請確認檔案仍存在且可存取。"
        case .invalidBackupFile:
            return "備份檔格式不正確，請選擇 FitPlanner 匯出的 JSON 備份。"
        case .unsupportedSchemaVersion(let version):
            return "不支援的備份版本：\(version)。目前僅支援 schemaVersion 1。"
        }
    }
}

final class BackupImportService {
    private let fitnessService: FitnessService

    init(fitnessService: FitnessService) {
        self.fitnessService = fitnessService
    }

    func importBackup(from fileURL: URL) throws {
        let didStartAccessing = fileURL.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }

        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            throw BackupImportError.unreadableFile
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let backup: FitPlannerBackup
        do {
            backup = try decoder.decode(FitPlannerBackup.self, from: data)
        } catch {
            throw BackupImportError.invalidBackupFile
        }

        guard backup.schemaVersion == 1 else {
            throw BackupImportError.unsupportedSchemaVersion(backup.schemaVersion)
        }

        fitnessService.saveUserProfile(backup.userProfile)
        fitnessService.upsertWorkoutRecords(backup.workoutRecords)
    }
}

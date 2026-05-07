import Foundation

final class BackupExportService {
    private let fitnessService: FitnessService
    private let fileManager: FileManager

    init(
        fitnessService: FitnessService,
        fileManager: FileManager = .default
    ) {
        self.fitnessService = fitnessService
        self.fileManager = fileManager
    }

    func exportBackup() throws -> URL {
        let backup = FitPlannerBackup(
            schemaVersion: 1,
            exportedAt: Date(),
            appName: "FitPlanner",
            includesSeedData: true,
            userProfile: fitnessService.userProfile(),
            workoutRecords: fitnessService.workoutRecords()
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(backup)
        let fileURL = fileManager.temporaryDirectory
            .appendingPathComponent(fileName(for: backup.exportedAt))

        try data.write(to: fileURL, options: [.atomic])
        return fileURL
    }

    private func fileName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return "FitPlanner-Backup-\(formatter.string(from: date)).json"
    }
}

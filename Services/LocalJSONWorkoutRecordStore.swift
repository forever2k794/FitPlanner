import Foundation

final class LocalJSONWorkoutRecordStore {
    private let fileManager: FileManager
    private let fileURL: URL

    init(
        fileManager: FileManager = .default,
        documentsDirectory: URL? = nil
    ) {
        self.fileManager = fileManager
        let baseDirectory = documentsDirectory ?? fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = baseDirectory
            .appendingPathComponent("FitPlanner", isDirectory: true)
            .appendingPathComponent("workout-records.json")
    }

    func loadRecords() -> [WorkoutSessionRecord] {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([WorkoutSessionRecord].self, from: data)
        } catch {
            return []
        }
    }

    func saveRecords(_ records: [WorkoutSessionRecord]) {
        do {
            try ensureDirectoryExists()

            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

            let data = try encoder.encode(records)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            return
        }
    }

    private func ensureDirectoryExists() throws {
        let directoryURL = fileURL.deletingLastPathComponent()
        guard !fileManager.fileExists(atPath: directoryURL.path) else {
            return
        }

        try fileManager.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
    }
}

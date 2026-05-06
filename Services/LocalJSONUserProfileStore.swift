import Foundation

final class LocalJSONUserProfileStore {
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
            .appendingPathComponent("user-profile.json")
    }

    func loadProfile() -> UserProfile? {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            return try decoder.decode(UserProfile.self, from: data)
        } catch {
            return nil
        }
    }

    func saveProfile(_ profile: UserProfile) {
        do {
            try ensureDirectoryExists()

            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

            let data = try encoder.encode(profile)
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

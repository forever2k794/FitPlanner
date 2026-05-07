import Foundation

struct FitPlannerBackup: Codable {
    var schemaVersion: Int
    var exportedAt: Date
    var appName: String
    var includesSeedData: Bool
    var userProfile: UserProfile
    var workoutRecords: [WorkoutSessionRecord]
}

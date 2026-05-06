import Foundation

struct UserProfile: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var heightInCentimeters: Double
    var weightInKilograms: Double
    var goal: String
    var experienceLevel: String
    var weeklyTargetTrainingDays: Int

    init(
        id: UUID = UUID(),
        name: String,
        heightInCentimeters: Double,
        weightInKilograms: Double,
        goal: String,
        experienceLevel: String,
        weeklyTargetTrainingDays: Int
    ) {
        self.id = id
        self.name = name
        self.heightInCentimeters = heightInCentimeters
        self.weightInKilograms = weightInKilograms
        self.goal = goal
        self.experienceLevel = experienceLevel
        self.weeklyTargetTrainingDays = weeklyTargetTrainingDays
    }
}

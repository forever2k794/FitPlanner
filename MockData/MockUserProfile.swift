import Foundation

enum MockUserProfile {
    static let current = UserProfile(
        name: "Jay",
        heightInCentimeters: 175,
        weightInKilograms: 72,
        goal: "增肌與力量提升",
        experienceLevel: "中階",
        weeklyTargetTrainingDays: 4
    )
}

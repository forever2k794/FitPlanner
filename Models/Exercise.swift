import Foundation

struct Exercise: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var primaryMuscleGroup: String
    var equipment: String
    var note: String

    init(
        id: UUID = UUID(),
        name: String,
        primaryMuscleGroup: String,
        equipment: String,
        note: String = ""
    ) {
        self.id = id
        self.name = name
        self.primaryMuscleGroup = primaryMuscleGroup
        self.equipment = equipment
        self.note = note
    }
}

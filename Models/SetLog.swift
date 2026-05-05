import Foundation

struct SetLog: Identifiable, Hashable {
    let id: UUID
    var setNumber: Int
    var weightInKilograms: Double
    var reps: Int
    var rpe: Double?
    var rir: Int?
    var isCompleted: Bool

    var volume: Double {
        weightInKilograms * Double(reps)
    }

    init(
        id: UUID = UUID(),
        setNumber: Int,
        weightInKilograms: Double,
        reps: Int,
        rpe: Double? = nil,
        rir: Int? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.setNumber = setNumber
        self.weightInKilograms = weightInKilograms
        self.reps = reps
        self.rpe = rpe
        self.rir = rir
        self.isCompleted = isCompleted
    }
}

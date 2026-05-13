import Foundation

enum MockExercises {
    static let all: [Exercise] = [
        exercise(
            name: "槓鈴臥推",
            primary: [.chest],
            secondary: [.shoulders, .triceps],
            equipment: [.barbell],
            focus: [.push, .chest, .fullBody],
            styles: [.strength, .hypertrophy],
            isCompound: true,
            sets: 4,
            reps: 6,
            note: "保持肩胛穩定，控制離心。"
        ),
        exercise(
            name: "啞鈴臥推",
            primary: [.chest],
            secondary: [.shoulders, .triceps],
            equipment: [.dumbbell],
            focus: [.push, .chest, .fullBody],
            styles: [.hypertrophy, .endurance],
            isCompound: true,
            sets: 3,
            reps: 10
        ),
        exercise(
            name: "上斜啞鈴臥推",
            primary: [.chest],
            secondary: [.shoulders, .triceps],
            equipment: [.dumbbell],
            focus: [.push, .chest],
            styles: [.hypertrophy],
            isCompound: true,
            sets: 3,
            reps: 10
        ),
        exercise(
            name: "肩推",
            primary: [.shoulders],
            secondary: [.triceps, .core],
            equipment: [.dumbbell, .barbell],
            focus: [.push, .shoulders, .fullBody],
            styles: [.strength, .hypertrophy],
            isCompound: true,
            sets: 3,
            reps: 8,
            note: "避免過度聳肩，核心收緊。"
        ),
        exercise(
            name: "機械胸推",
            primary: [.chest],
            secondary: [.shoulders, .triceps],
            equipment: [.machine],
            focus: [.push, .chest],
            styles: [.hypertrophy, .endurance, .recovery],
            isCompound: true,
            sets: 3,
            reps: 10
        ),
        exercise(
            name: "繩索下壓",
            primary: [.triceps],
            secondary: [],
            equipment: [.cable],
            focus: [.push, .arms],
            styles: [.hypertrophy, .endurance, .recovery],
            isCompound: false,
            sets: 3,
            reps: 12
        ),
        exercise(
            name: "側平舉",
            primary: [.shoulders],
            secondary: [],
            equipment: [.dumbbell, .cable],
            focus: [.push, .shoulders],
            styles: [.hypertrophy, .endurance, .recovery],
            isCompound: false,
            sets: 3,
            reps: 15,
            note: "重量保守，避免借力甩動。"
        ),
        exercise(
            name: "引體向上",
            primary: [.back],
            secondary: [.biceps, .core],
            equipment: [.bodyweight],
            focus: [.pull, .back, .fullBody],
            styles: [.strength, .hypertrophy],
            isCompound: true,
            sets: 4,
            reps: 6
        ),
        exercise(
            name: "滑輪下拉",
            primary: [.back],
            secondary: [.biceps],
            equipment: [.cable, .machine],
            focus: [.pull, .back],
            styles: [.hypertrophy, .endurance, .recovery],
            isCompound: true,
            sets: 3,
            reps: 10,
            note: "下拉至上胸，避免身體過度後仰。"
        ),
        exercise(
            name: "坐姿划船",
            primary: [.back],
            secondary: [.biceps],
            equipment: [.cable, .machine],
            focus: [.pull, .back],
            styles: [.hypertrophy, .endurance, .recovery],
            isCompound: true,
            sets: 3,
            reps: 10
        ),
        exercise(
            name: "槓鈴划船",
            primary: [.back],
            secondary: [.biceps, .core],
            equipment: [.barbell],
            focus: [.pull, .back, .fullBody],
            styles: [.strength, .hypertrophy],
            isCompound: true,
            sets: 4,
            reps: 8,
            note: "手肘往後帶，感受背部收縮。"
        ),
        exercise(
            name: "啞鈴划船",
            primary: [.back],
            secondary: [.biceps],
            equipment: [.dumbbell],
            focus: [.pull, .back],
            styles: [.hypertrophy],
            isCompound: true,
            sets: 3,
            reps: 10
        ),
        exercise(
            name: "面拉",
            primary: [.shoulders],
            secondary: [.back],
            equipment: [.cable],
            focus: [.pull, .back, .shoulders],
            styles: [.hypertrophy, .endurance, .recovery],
            isCompound: false,
            sets: 3,
            reps: 15
        ),
        exercise(
            name: "二頭彎舉",
            primary: [.biceps],
            secondary: [],
            equipment: [.dumbbell, .cable, .barbell],
            focus: [.pull, .arms],
            styles: [.hypertrophy, .endurance],
            isCompound: false,
            sets: 3,
            reps: 12
        ),
        exercise(
            name: "深蹲",
            primary: [.quads],
            secondary: [.glutes, .hamstrings, .core],
            equipment: [.barbell, .smithMachine],
            focus: [.legs, .fullBody],
            styles: [.strength, .hypertrophy],
            isCompound: true,
            sets: 4,
            reps: 6,
            note: "主要訓練股四頭肌、臀肌與核心穩定。"
        ),
        exercise(
            name: "腿推",
            primary: [.quads],
            secondary: [.glutes],
            equipment: [.machine],
            focus: [.legs],
            styles: [.hypertrophy, .endurance, .recovery],
            isCompound: true,
            sets: 3,
            reps: 10,
            note: "膝蓋方向與腳尖一致。"
        ),
        exercise(
            name: "羅馬尼亞硬舉",
            primary: [.hamstrings],
            secondary: [.glutes, .back],
            equipment: [.barbell, .dumbbell],
            focus: [.legs, .pull, .fullBody],
            styles: [.strength, .hypertrophy],
            isCompound: true,
            sets: 3,
            reps: 8
        ),
        exercise(
            name: "腿伸展",
            primary: [.quads],
            secondary: [],
            equipment: [.machine],
            focus: [.legs],
            styles: [.hypertrophy, .endurance, .recovery],
            isCompound: false,
            sets: 3,
            reps: 12
        ),
        exercise(
            name: "腿彎舉",
            primary: [.hamstrings],
            secondary: [],
            equipment: [.machine],
            focus: [.legs],
            styles: [.hypertrophy, .endurance, .recovery],
            isCompound: false,
            sets: 3,
            reps: 12,
            note: "頂峰停留一拍，控制回放。"
        ),
        exercise(
            name: "臀推",
            primary: [.glutes],
            secondary: [.hamstrings, .core],
            equipment: [.barbell, .machine],
            focus: [.legs],
            styles: [.strength, .hypertrophy],
            isCompound: true,
            sets: 4,
            reps: 8
        ),
        exercise(
            name: "小腿提踵",
            primary: [.calves],
            secondary: [],
            equipment: [.machine, .dumbbell, .bodyweight],
            focus: [.legs],
            styles: [.hypertrophy, .endurance, .recovery],
            isCompound: false,
            sets: 3,
            reps: 15
        ),
        exercise(
            name: "平板支撐",
            primary: [.core],
            secondary: [.shoulders, .glutes],
            equipment: [.bodyweight],
            focus: [.core, .fullBody],
            styles: [.endurance, .recovery],
            isCompound: false,
            sets: 3,
            reps: 30
        ),
        exercise(
            name: "捲腹",
            primary: [.core],
            secondary: [],
            equipment: [.bodyweight],
            focus: [.core],
            styles: [.endurance, .recovery],
            isCompound: false,
            sets: 3,
            reps: 15
        ),
        exercise(
            name: "懸垂舉腿",
            primary: [.core],
            secondary: [],
            equipment: [.bodyweight],
            focus: [.core, .pull],
            styles: [.hypertrophy, .endurance],
            isCompound: false,
            sets: 3,
            reps: 10
        ),
        exercise(
            name: "Cable Crunch",
            primary: [.core],
            secondary: [],
            equipment: [.cable],
            focus: [.core],
            styles: [.hypertrophy, .endurance],
            isCompound: false,
            sets: 3,
            reps: 12
        )
    ]

    static func exercise(named name: String) -> Exercise {
        let aliases = [
            "臥推": "槓鈴臥推",
            "硬舉": "羅馬尼亞硬舉",
            "划船": "槓鈴划船",
            "腹部訓練": "捲腹",
            "滑輪機下拉": "滑輪下拉"
        ]
        let normalizedName = aliases[name] ?? name
        return all.first { $0.name == normalizedName } ?? all[0]
    }

    private static func exercise(
        name: String,
        primary: [MuscleGroup],
        secondary: [MuscleGroup],
        equipment: [EquipmentType],
        focus: [WorkoutFocusType],
        styles: [TrainingStyle],
        isCompound: Bool,
        sets: Int,
        reps: Int,
        note: String = ""
    ) -> Exercise {
        Exercise(
            name: name,
            primaryMuscleGroup: primary.first?.displayName ?? "全身",
            equipment: equipment.map(\.displayName).joined(separator: " / "),
            note: note,
            primaryMuscleGroups: primary,
            secondaryMuscleGroups: secondary,
            equipmentTypes: equipment,
            supportedFocusTypes: focus.contains(.custom) ? focus : focus + [.custom],
            supportedTrainingStyles: styles,
            isCompound: isCompound,
            defaultSets: sets,
            defaultReps: reps
        )
    }
}

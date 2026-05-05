import Foundation

enum MockExercises {
    static let all: [Exercise] = [
        Exercise(name: "深蹲", primaryMuscleGroup: "腿部", equipment: "槓鈴", note: "主要訓練股四頭肌、臀肌與核心穩定。"),
        Exercise(name: "臥推", primaryMuscleGroup: "胸部", equipment: "槓鈴", note: "保持肩胛穩定，控制離心。"),
        Exercise(name: "硬舉", primaryMuscleGroup: "背部", equipment: "槓鈴", note: "髖鉸鏈發力，背部維持中立。"),
        Exercise(name: "肩推", primaryMuscleGroup: "肩部", equipment: "啞鈴", note: "避免過度聳肩，核心收緊。"),
        Exercise(name: "划船", primaryMuscleGroup: "背部", equipment: "槓鈴", note: "手肘往後帶，感受背部收縮。"),
        Exercise(name: "滑輪下拉", primaryMuscleGroup: "背部", equipment: "滑輪機", note: "下拉至上胸，避免身體過度後仰。"),
        Exercise(name: "腿推", primaryMuscleGroup: "腿部", equipment: "腿推機", note: "膝蓋方向與腳尖一致。"),
        Exercise(name: "腿彎舉", primaryMuscleGroup: "腿後側", equipment: "腿彎舉機", note: "頂峰停留一拍，控制回放。"),
        Exercise(name: "側平舉", primaryMuscleGroup: "肩部", equipment: "啞鈴", note: "重量保守，避免借力甩動。"),
        Exercise(name: "腹部訓練", primaryMuscleGroup: "核心", equipment: "徒手", note: "保持骨盆穩定，避免腰椎代償。")
    ]

    static func exercise(named name: String) -> Exercise {
        all.first { $0.name == name } ?? all[0]
    }
}

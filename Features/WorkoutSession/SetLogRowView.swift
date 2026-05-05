import Foundation
import SwiftUI

struct SetLogRowView: View {
    let setLog: SetLog
    let onUpdate: (SetLog) -> Void

    @State private var weightText: String
    @State private var reps: Int
    @State private var rpe: Double
    @State private var rir: Int
    @State private var isCompleted: Bool

    init(setLog: SetLog, onUpdate: @escaping (SetLog) -> Void) {
        self.setLog = setLog
        self.onUpdate = onUpdate
        _weightText = State(initialValue: Self.formattedWeight(setLog.weightInKilograms))
        _reps = State(initialValue: setLog.reps)
        _rpe = State(initialValue: setLog.rpe ?? 7)
        _rir = State(initialValue: setLog.rir ?? 2)
        _isCompleted = State(initialValue: setLog.isCompleted)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("第 \(setLog.setNumber) 組")
                    .font(.headline)

                Spacer()

                Toggle("完成", isOn: $isCompleted)
                    .labelsHidden()
            }

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("重量 kg")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField("0", text: $weightText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                    }

                    Stepper(value: $reps, in: 0...100) {
                        metricText(title: "次數", value: "\(reps)")
                    }
                }

                Stepper(value: $rpe, in: 1...10, step: 0.5) {
                    metricText(title: "RPE", value: String(format: "%.1f", rpe))
                }

                Stepper(value: $rir, in: 0...10) {
                    metricText(title: "RIR", value: "\(rir)")
                }
            }
        }
        .padding(14)
        .background(.background, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
        )
        .onChange(of: weightText) { _, _ in
            emitUpdate()
        }
        .onChange(of: reps) { _, _ in
            emitUpdate()
        }
        .onChange(of: rpe) { _, _ in
            emitUpdate()
        }
        .onChange(of: rir) { _, _ in
            emitUpdate()
        }
        .onChange(of: isCompleted) { _, _ in
            emitUpdate()
        }
        .onChange(of: setLog) { _, newValue in
            sync(from: newValue)
        }
    }

    private func metricText(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.semibold))
        }
    }

    private func emitUpdate() {
        var updatedSetLog = setLog
        updatedSetLog.weightInKilograms = parsedWeight()
        updatedSetLog.reps = reps
        updatedSetLog.rpe = rpe
        updatedSetLog.rir = rir
        updatedSetLog.isCompleted = isCompleted
        onUpdate(updatedSetLog)
    }

    private func parsedWeight() -> Double {
        let normalizedText = weightText.replacingOccurrences(of: ",", with: ".")
        return max(Double(normalizedText) ?? setLog.weightInKilograms, 0)
    }

    private func sync(from setLog: SetLog) {
        weightText = Self.formattedWeight(setLog.weightInKilograms)
        reps = setLog.reps
        rpe = setLog.rpe ?? 7
        rir = setLog.rir ?? 2
        isCompleted = setLog.isCompleted
    }

    private static func formattedWeight(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        }

        return String(format: "%.1f", value)
    }
}

#Preview {
    SetLogRowView(
        setLog: SetLog(
            setNumber: 1,
            weightInKilograms: 72.5,
            reps: 8,
            rpe: 8,
            rir: 2,
            isCompleted: false
        ),
        onUpdate: { _ in }
    )
    .padding()
}

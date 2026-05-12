import SwiftUI

struct WorkoutDaySummaryCardView: View {
    let record: WorkoutSessionRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.green)
                    .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text(record.title)
                        .font(.headline)

                    Text(record.date.fitPlannerShortDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            HStack(spacing: 10) {
                summaryPill(
                    title: "動作",
                    value: "\(record.exerciseLogs.count)"
                )

                summaryPill(
                    title: "完成組數",
                    value: "\(completedSetCount)"
                )

                summaryPill(
                    title: "總容量",
                    value: NumberFormatting.volume(record.totalVolume)
                )
            }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var completedSetCount: Int {
        record.exerciseLogs
            .flatMap(\.sets)
            .filter(\.isCompleted)
            .count
    }

    private func summaryPill(title: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    WorkoutDaySummaryCardView(record: MockWorkoutRecords.history[0])
        .padding()
}

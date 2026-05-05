import SwiftUI

struct StatCardView: View {
    let title: String
    let value: String
    let subtitle: String?
    let systemImage: String
    let tint: Color

    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        systemImage: String,
        tint: Color = .blue
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tint = tint
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(tint)

                Spacer()
            }

            Text(value)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    StatCardView(
        title: "本週完成率",
        value: "75%",
        subtitle: "目標每週 4 天",
        systemImage: "checkmark.circle.fill",
        tint: .green
    )
    .padding()
}

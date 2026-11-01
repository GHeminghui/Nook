import SwiftUI
import SwiftData
import Foundation

struct TagFilterBar: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Tag.name) private var tags: [Tag]
    @Binding var criteria: SearchService.Criteria

    var body: some View {
        if !tags.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tags) { tag in
                        tagChip(tag)
                            .contextMenu {
                                Button("删除标签", role: .destructive) {
                                    context.delete(tag)
                                    try? context.save()
                                    criteria.tagIDs.remove(tag.id)
                                }
                            }
                    }

                    Divider()
                        .frame(height: 18)

                    Button {
                        criteria.matchAllTags.toggle()
                    } label: {
                        Text(criteria.matchAllTags ? String(localized: "同时满足") : String(localized: "满足任一"))
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(.tertiarySystemBackground), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
            }
        }
    }

    private func tagChip(_ tag: Tag) -> some View {
        let selected = criteria.tagIDs.contains(tag.id)
        return Button {
            if selected {
                criteria.tagIDs.remove(tag.id)
            } else {
                criteria.tagIDs.insert(tag.id)
            }
        } label: {
            HStack(spacing: 4) {
                Circle()
                    .fill(Color(hex: tag.colorHex))
                    .frame(width: 8, height: 8)
                Text(tag.name)
                    .font(.caption)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                selected ? Color.accentColor.opacity(0.2) : Color(.tertiarySystemBackground),
                in: Capsule()
            )
            .overlay(
                Capsule().stroke(selected ? Color.accentColor : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r, g, b: Double
        if cleaned.count == 6 {
            r = Double((value & 0xFF0000) >> 16) / 255
            g = Double((value & 0x00FF00) >> 8) / 255
            b = Double(value & 0x0000FF) / 255
        } else {
            r = 0.23; g = 0.42; b = 0.96
        }
        self.init(red: r, green: g, blue: b)
    }
}

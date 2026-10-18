import SwiftUI
import SwiftData

struct ItemGrid: View {
    @Query(sort: \Item.importedAt, order: .reverse) private var items: [Item]
    let store: LibraryStore
    let criteria: SearchService.Criteria
    let folderScope: Folder?

    @State private var pendingDelete: Item?

    private var filteredItems: [Item] {
        var effective = criteria
        effective.folderScope = folderScope?.id

        return items.filter { item in
            let snapshot = SearchService.Snapshot(
                id: item.id,
                folderID: item.folder?.id ?? UUID(),
                folderAncestors: store.ancestors(of: item.folder),
                fileName: item.fileName,
                textContent: item.textContent,
                tagIDs: item.tags.map(\.id)
            )
            return SearchService.matches(snapshot, effective)
        }
    }

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    var body: some View {
        Group {
            if filteredItems.isEmpty {
                ContentUnavailableView(
                    criteria.text.isEmpty && criteria.tagIDs.isEmpty ? "还没有资料" : "没有匹配的资料",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text(criteria.text.isEmpty ? "点右上角「导入」添加资料" : "换个关键词或标签试试")
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredItems) { item in
                            NavigationLink {
                                PreviewContainer(item: item, url: store.absoluteURL(for: item))
                            } label: {
                                ItemCell(item: item)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button("删除", systemImage: "trash", role: .destructive) {
                                    pendingDelete = item
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .confirmationDialog("删除这份资料？", isPresented: Binding(
            get: { pendingDelete != nil },
            set: { if !$0 { pendingDelete = nil } }
        ), titleVisibility: .visible) {
            Button("删除", role: .destructive) {
                if let item = pendingDelete {
                    try? store.deleteItem(item)
                }
                pendingDelete = nil
            }
            Button("取消", role: .cancel) { pendingDelete = nil }
        } message: {
            Text("文件会同时从磁盘移除，操作不可撤销。")
        }
    }
}

struct ItemCell: View {
    let item: Item

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
                .frame(height: 110)
                .overlay {
                    Image(systemName: iconName)
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary)
                }

            Text(item.fileName)
                .font(.subheadline)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            HStack(spacing: 4) {
                Text(item.kind.rawValue.uppercased())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(ByteCountFormatter.string(fromByteCount: Int64(item.size), countStyle: .file))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if !item.tags.isEmpty {
                Text(item.tags.map(\.name).joined(separator: " · "))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(10)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator).opacity(0.5), lineWidth: 0.5)
        }
    }

    private var iconName: String {
        switch item.kind {
        case .pdf: return "doc.richtext"
        case .image: return "photo"
        case .html: return "globe"
        case .other: return "doc"
        }
    }
}

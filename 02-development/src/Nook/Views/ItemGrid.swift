import SwiftUI
import SwiftData

struct ItemGrid: View {
    @Query(sort: [SortDescriptor(\Item.sortOrder), SortDescriptor(\Item.importedAt, order: .reverse)])
    private var items: [Item]
    @Query(sort: [SortDescriptor(\Folder.sortOrder), SortDescriptor(\Folder.name)])
    private var folders: [Folder]
    let store: LibraryStore
    let criteria: SearchService.Criteria
    let folderScope: Folder?
    let onOpenFolder: (Folder) -> Void

    @State private var pendingDelete: Item?
    @State private var renameTarget: Item?
    @State private var renameText = ""
    @State private var activeAction: ItemAction?
    @State private var targetedItemID: UUID?

    private enum ItemAction: Identifiable {
        case tags(Item)
        case move(Item)

        var id: String {
            switch self {
            case .tags(let item): return "tags-\(item.id)"
            case .move(let item): return "move-\(item.id)"
            }
        }
    }

    private var isFiltering: Bool {
        !criteria.text.isEmpty || !criteria.tagIDs.isEmpty
    }

    private var childFolders: [Folder] {
        guard let folderScope else { return [] }
        return folders
            .filter { $0.parent?.id == folderScope.id }
            .sorted { lhs, rhs in
                if lhs.sortOrder != rhs.sortOrder { return lhs.sortOrder < rhs.sortOrder }
                return lhs.name < rhs.name
            }
    }

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
            if filteredItems.isEmpty && (isFiltering || childFolders.isEmpty) {
                ContentUnavailableView(
                    isFiltering ? "没有匹配的资料" : "还没有资料",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text(isFiltering ? "换个关键词或标签试试" : "点右上角「导入」添加资料")
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        if !isFiltering {
                            ForEach(childFolders) { folder in
                                Button {
                                    onOpenFolder(folder)
                                } label: {
                                    FolderCell(folder: folder)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        ForEach(filteredItems) { item in
                            Group {
                                if item.kind == .pdf {
                                    Button {
                                        openInQuickLook(item)
                                    } label: {
                                        itemLabel(item)
                                    }
                                } else {
                                    NavigationLink {
                                        PreviewContainer(item: item, store: store)
                                    } label: {
                                        itemLabel(item)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .draggable(DragPayload.item(item.id))
                            .dropDestination(for: String.self) { payloads, _ in
                                handleItemDrop(payloads, on: item)
                            } isTargeted: { targeted in
                                if targeted {
                                    targetedItemID = item.id
                                } else if targetedItemID == item.id {
                                    targetedItemID = nil
                                }
                            }
                            .contextMenu {
                                Button("重命名", systemImage: "pencil") {
                                    renameText = (item.fileName as NSString).deletingPathExtension
                                    renameTarget = item
                                }
                                Button("编辑标签", systemImage: "tag") {
                                    activeAction = .tags(item)
                                }
                                Button("移动到…", systemImage: "folder") {
                                    activeAction = .move(item)
                                }
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
        .alert("重命名", isPresented: Binding(
            get: { renameTarget != nil },
            set: { if !$0 { renameTarget = nil } }
        )) {
            TextField("名称", text: $renameText)
            Button("确定") {
                if let item = renameTarget {
                    try? store.renameItem(item, to: renameText)
                }
                renameTarget = nil
            }
            Button("取消", role: .cancel) { renameTarget = nil }
        } message: {
            Text("扩展名会自动保留。")
        }
        .sheet(item: $activeAction) { action in
            switch action {
            case .tags(let item):
                ItemTagEditor(store: store, item: item)
            case .move(let item):
                MoveItemSheet(store: store, item: item)
            }
        }
    }

    private func itemLabel(_ item: Item) -> some View {
        ItemCell(item: item)
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        targetedItemID == item.id ? Color.accentColor : .clear,
                        lineWidth: 2
                    )
            }
    }

    /// PDF 直接用系统 Quick Look 打开，阅读与标注都在系统界面里完成。
    private func openInQuickLook(_ item: Item) {
        let destination = store.absoluteURL(for: item)
        PDFMarkupPresenter.shared.open(url: destination) { editedURL in
            if editedURL.standardizedFileURL != destination.standardizedFileURL {
                if let data = try? Data(contentsOf: editedURL) {
                    try? data.write(to: destination, options: .atomic)
                }
            }
            store.markEdited(item, reindex: false)
        }
    }

    private func handleItemDrop(_ payloads: [String], on target: Item) -> Bool {
        for payload in payloads {
            guard case .item(let id) = DragPayload.parse(payload), id != target.id else { continue }
            let descriptor = FetchDescriptor<Item>(predicate: #Predicate { $0.id == id })
            guard let source = (try? store.context.fetch(descriptor))?.first else { continue }

            if source.folder?.id == target.folder?.id {
                let siblings = items.filter { $0.folder?.id == target.folder?.id }
                if let from = siblings.firstIndex(where: { $0.id == source.id }),
                   let to = siblings.firstIndex(where: { $0.id == target.id }) {
                    try? store.reorderItem(source, relativeTo: target, placeAfter: from < to)
                    return true
                }
            }

            try? store.reorderItem(source, relativeTo: target)
            return true
        }
        return false
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

struct FolderCell: View {
    let folder: Folder

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.accentColor.opacity(0.08))
                .frame(height: 110)
                .overlay {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(.tint)
                }

            Text(folder.name)
                .font(.subheadline)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Text(String(format: String(localized: "%lld 份资料"), folder.items.count))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator).opacity(0.5), lineWidth: 0.5)
        }
    }
}

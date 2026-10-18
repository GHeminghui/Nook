import SwiftUI
import SwiftData

struct FolderSidebar: View {
    @Query(sort: [SortDescriptor(\Folder.sortOrder), SortDescriptor(\Folder.name)])
    private var folders: [Folder]
    @Binding var selection: Folder?
    let store: LibraryStore?

    @State private var renameTarget: Folder?
    @State private var renameText = ""
    @State private var newSubfolderParent: Folder?
    @State private var newSubfolderName = ""
    @State private var newSubfolderLocation = ""
    @State private var moveTarget: Folder?
    @State private var deleteTarget: Folder?
    @State private var targetedFolderID: UUID?
    @State private var isRootTargeted = false
    @State private var expandedFolderIDs: Set<UUID> = []

    private struct FolderOption: Identifiable {
        let folder: Folder
        let depth: Int

        var id: UUID { folder.id }
    }

    private var rootFolders: [Folder] {
        folders
            .filter { $0.parent == nil }
            .sorted { lhs, rhs in
                if lhs.sortOrder != rhs.sortOrder { return lhs.sortOrder < rhs.sortOrder }
                return lhs.name < rhs.name
            }
    }

    private var options: [FolderOption] {
        var result: [FolderOption] = []

        func walk(_ folder: Folder, depth: Int) {
            result.append(FolderOption(folder: folder, depth: depth))
            guard expandedFolderIDs.contains(folder.id) else { return }
            for child in folder.sortedChildren {
                walk(child, depth: depth + 1)
            }
        }

        for root in rootFolders {
            walk(root, depth: 0)
        }
        return result
    }

    var body: some View {
        List {
            Section {
                Button {
                    selection = nil
                } label: {
                    folderLabel("全部资料", systemImage: "tray.full")
                }
                .listRowBackground(rowBackground(
                    isSelected: selection == nil,
                    isTargeted: isRootTargeted
                ))
                .dropDestination(for: String.self) { payloads, _ in
                    handleDrop(payloads, to: nil)
                } isTargeted: { targeted in
                    isRootTargeted = targeted
                }
            }

            Section("文件夹") {
                ForEach(options) { option in
                    HStack(spacing: 4) {
                        Button {
                            handleTap(option.folder)
                        } label: {
                            folderLabel(option.folder.name, systemImage: "folder")
                        }
                        .buttonStyle(.plain)

                        if option.folder.sortedChildren.isEmpty {
                            Color.clear
                                .frame(width: 16, height: 16)
                        } else {
                            Button {
                                toggleExpansion(option.folder)
                            } label: {
                                Image(systemName: expandedFolderIDs.contains(option.folder.id)
                                      ? "chevron.down" : "chevron.right")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 16, height: 16)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.leading, CGFloat(option.depth) * 16)
                    .frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
                    .contentShape(Rectangle())
                    .draggable(DragPayload.folder(option.folder.id))
                    .listRowBackground(rowBackground(
                        isSelected: selection?.id == option.folder.id,
                        isTargeted: targetedFolderID == option.folder.id
                    ))
                    .dropDestination(for: String.self) { payloads, _ in
                        handleDrop(payloads, to: option.folder)
                    } isTargeted: { targeted in
                        if targeted {
                            targetedFolderID = option.folder.id
                        } else if targetedFolderID == option.folder.id {
                            targetedFolderID = nil
                        }
                    }
                    .contextMenu {
                        Button("新建子文件夹", systemImage: "folder.badge.plus") {
                            newSubfolderName = ""
                            newSubfolderParent = option.folder
                            newSubfolderLocation = folderPath(for: option.folder)
                        }
                        Button("上移", systemImage: "arrow.up") {
                            shiftFolder(option.folder, by: -1)
                        }
                        Button("下移", systemImage: "arrow.down") {
                            shiftFolder(option.folder, by: 1)
                        }
                        Divider()
                        Button("重命名", systemImage: "pencil") {
                            renameText = option.folder.name
                            renameTarget = option.folder
                        }
                        Button("移动到…", systemImage: "folder") {
                            moveTarget = option.folder
                        }
                        Button(deleteTitle(for: option.folder), systemImage: "trash", role: .destructive) {
                            deleteTarget = option.folder
                        }
                        .disabled(!canDelete(option.folder))
                    }
                    .popover(
                        isPresented: deleteBinding(for: option.folder),
                        attachmentAnchor: .rect(.bounds),
                        arrowEdge: .leading
                    ) {
                        deleteConfirmation(for: option.folder)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .onChange(of: selection?.id) { _, _ in
            expandAncestorsOfSelection()
        }
        .sheet(item: $moveTarget) { folder in
            if let store {
                MoveFolderSheet(store: store, folder: folder)
            }
        }
        .alert("新建子文件夹", isPresented: Binding(
            get: { newSubfolderParent != nil },
            set: { if !$0 { newSubfolderParent = nil } }
        )) {
            TextField("文件夹名称", text: $newSubfolderName)
            Button("取消", role: .cancel) { newSubfolderParent = nil }
            Button("创建") {
                if let store, let parent = newSubfolderParent {
                    if let folder = try? store.createFolder(named: newSubfolderName, parent: parent) {
                        expandedFolderIDs.insert(parent.id)
                        selection = folder
                    }
                }
                newSubfolderParent = nil
            }
            .disabled(newSubfolderName.trimmingCharacters(in: .whitespaces).isEmpty)
        } message: {
            Text("创建位置：\(newSubfolderLocation)")
        }
        .alert("重命名文件夹", isPresented: Binding(
            get: { renameTarget != nil },
            set: { if !$0 { renameTarget = nil } }
        )) {
            TextField("文件夹名称", text: $renameText)
            Button("取消", role: .cancel) { renameTarget = nil }
            Button("保存") {
                if let store, let target = renameTarget {
                    try? store.renameFolder(target, to: renameText)
                }
                renameTarget = nil
            }
        }
    }

    private func deleteBinding(for folder: Folder) -> Binding<Bool> {
        Binding(
            get: { deleteTarget?.id == folder.id },
            set: { presented in
                if !presented, deleteTarget?.id == folder.id {
                    deleteTarget = nil
                }
            }
        )
    }

    private func deleteConfirmation(for folder: Folder) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("删除文件夹？")
                .font(.headline)
            Text("只会删除空文件夹（含空子文件夹），不会删除任何文件。操作不可撤销。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack {
                Spacer()
                Button("取消", role: .cancel) { deleteTarget = nil }
                Button("删除", role: .destructive) { performDelete(folder) }
            }
        }
        .padding()
        .frame(width: 300)
        .presentationCompactAdaptation(.popover)
    }

    private func performDelete(_ target: Folder) {
        defer { deleteTarget = nil }
        guard let store else { return }
        do {
            try store.deleteFolder(target)
            if let selection, store.ancestors(of: selection).contains(target.id) {
                self.selection = nil
            }
        } catch {
            // 文件夹内仍有文件时，服务层会拒绝删除。
        }
    }

    private func handleTap(_ folder: Folder) {
        if selection?.id == folder.id {
            if !folder.sortedChildren.isEmpty {
                toggleExpansion(folder)
            }
        } else {
            selection = folder
        }
    }

    private func toggleExpansion(_ folder: Folder) {
        if expandedFolderIDs.contains(folder.id) {
            expandedFolderIDs.remove(folder.id)
        } else {
            expandedFolderIDs.insert(folder.id)
        }
    }

    private func shiftFolder(_ folder: Folder, by offset: Int) {
        guard let store else { return }
        let siblings = folders.filter { $0.parent?.id == folder.parent?.id }
        guard let index = siblings.firstIndex(where: { $0.id == folder.id }) else { return }
        let targetIndex = index + offset
        guard siblings.indices.contains(targetIndex) else { return }
        try? store.reorderFolder(
            folder,
            relativeTo: siblings[targetIndex],
            placeAfter: offset > 0
        )
    }

    private func expandAncestorsOfSelection() {
        guard let selection else { return }
        var current: Folder? = selection
        while let folder = current {
            expandedFolderIDs.insert(folder.id)
            current = folder.parent
        }
    }

    private func folderLabel(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
    }

    private func folderPath(for folder: Folder) -> String {
        var names: [String] = []
        var current: Folder? = folder
        while let item = current {
            names.append(item.name)
            current = item.parent
        }
        return names.isEmpty ? "顶层" : Array(names.reversed()).joined(separator: " / ")
    }

    private func canDelete(_ folder: Folder) -> Bool {
        guard let store else { return false }
        return !store.folderContainsItems(folder)
    }

    private func deleteTitle(for folder: Folder) -> String {
        canDelete(folder) ? "删除" : "删除（需先清空文件）"
    }

    private func rowBackground(isSelected: Bool, isTargeted: Bool) -> Color {
        if isTargeted { return Color.accentColor.opacity(0.3) }
        return isSelected ? Color.accentColor.opacity(0.15) : Color.clear
    }

    private func handleDrop(_ payloads: [String], to target: Folder?) -> Bool {
        guard let store else { return false }
        var handled = false

        for payload in payloads {
            switch DragPayload.parse(payload) {
            case .item(let id):
                guard let item = fetchItem(id) else { continue }
                try? store.moveItem(item, to: target)
                handled = true
            case .folder(let id):
                guard let folder = folders.first(where: { $0.id == id }),
                      folder.id != target?.id else { continue }
                if let target, folder.parent?.id == target.parent?.id {
                    let siblings = folders
                        .filter { $0.parent?.id == folder.parent?.id }
                        .sorted { lhs, rhs in
                            if lhs.sortOrder != rhs.sortOrder { return lhs.sortOrder < rhs.sortOrder }
                            return lhs.name < rhs.name
                        }
                    if let from = siblings.firstIndex(where: { $0.id == folder.id }),
                       let to = siblings.firstIndex(where: { $0.id == target.id }) {
                        try? store.reorderFolder(folder, relativeTo: target, placeAfter: from < to)
                    }
                } else {
                    try? store.moveFolder(folder, to: target)
                    if let target {
                        expandedFolderIDs.insert(target.id)
                    }
                }
                handled = true
            case .none:
                continue
            }
        }
        return handled
    }

    private func fetchItem(_ id: UUID) -> Item? {
        guard let store else { return nil }
        let descriptor = FetchDescriptor<Item>(predicate: #Predicate { $0.id == id })
        return (try? store.context.fetch(descriptor))?.first
    }
}

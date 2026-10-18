import SwiftUI
import SwiftData

struct MoveFolderSheet: View {
    let store: LibraryStore
    let folder: Folder

    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor(\Folder.sortOrder), SortDescriptor(\Folder.name)])
    private var folders: [Folder]
    @State private var selection: UUID?
    @State private var initialized = false

    private var excludedIDs: Set<UUID> {
        var ids: Set<UUID> = [folder.id]
        func collect(_ current: Folder) {
            for child in current.children {
                ids.insert(child.id)
                collect(child)
            }
        }
        collect(folder)
        return ids
    }

    private var options: [FolderOption] {
        let excluded = excludedIDs
        var result: [FolderOption] = []

        func walk(_ current: Folder, depth: Int) {
            guard !excluded.contains(current.id) else { return }
            result.append(FolderOption(folder: current, depth: depth))
            for child in current.sortedChildren {
                walk(child, depth: depth + 1)
            }
        }

        for root in folders where root.parent == nil {
            walk(root, depth: 0)
        }
        return result
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        selection = nil
                    } label: {
                        row("顶层", systemImage: "tray.full", isSelected: selection == nil)
                    }
                    .buttonStyle(.plain)
                }

                Section("文件夹") {
                    ForEach(options) { option in
                        Button {
                            selection = option.folder.id
                        } label: {
                            row(
                                option.folder.name,
                                systemImage: "folder",
                                isSelected: selection == option.folder.id
                            )
                            .padding(.leading, CGFloat(option.depth) * 16)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("移动文件夹")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("移动") {
                        let target = folders.first { $0.id == selection }
                        try? store.moveFolder(folder, to: target)
                        dismiss()
                    }
                }
            }
            .onAppear {
                guard !initialized else { return }
                selection = folder.parent?.id
                initialized = true
            }
        }
    }

    private func row(_ title: String, systemImage: String, isSelected: Bool) -> some View {
        HStack {
            Label(title, systemImage: systemImage)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
            }
        }
        .contentShape(Rectangle())
    }
}

private struct FolderOption: Identifiable {
    let folder: Folder
    let depth: Int

    var id: UUID { folder.id }
}

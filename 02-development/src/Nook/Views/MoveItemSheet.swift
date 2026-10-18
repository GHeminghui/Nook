import SwiftUI
import SwiftData

struct MoveItemSheet: View {
    let store: LibraryStore
    let item: Item

    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor(\Folder.sortOrder), SortDescriptor(\Folder.name)])
    private var folders: [Folder]
    @State private var selection: UUID?
    @State private var initialized = false

    private var rootFolders: [Folder] {
        folders.filter { $0.parent == nil }
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
                    OutlineGroup(rootFolders, children: \.optionalChildren) { folder in
                        Button {
                            selection = folder.id
                        } label: {
                            row(folder.name, systemImage: "folder", isSelected: selection == folder.id)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("移动到")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("移动") {
                        let target = folders.first { $0.id == selection }
                        try? store.moveItem(item, to: target)
                        dismiss()
                    }
                }
            }
            .onAppear {
                guard !initialized else { return }
                selection = item.folder?.id
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

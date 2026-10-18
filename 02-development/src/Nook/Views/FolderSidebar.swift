import SwiftUI
import SwiftData

struct FolderSidebar: View {
    @Query(sort: [SortDescriptor(\Folder.sortOrder), SortDescriptor(\Folder.name)])
    private var folders: [Folder]
    @Binding var selection: Folder?

    private var rootFolders: [Folder] {
        folders.filter { $0.parent == nil }
    }

    var body: some View {
        List {
            Section {
                Button {
                    selection = nil
                } label: {
                    folderLabel("全部资料", systemImage: "tray.full")
                }
                .listRowBackground(rowBackground(isSelected: selection == nil))
            }

            Section("文件夹") {
                OutlineGroup(rootFolders, children: \.optionalChildren) { folder in
                    Button {
                        selection = folder
                    } label: {
                        folderLabel(folder.name, systemImage: "folder")
                    }
                    .listRowBackground(rowBackground(isSelected: selection?.id == folder.id))
                }
            }
        }
        .listStyle(.sidebar)
    }

    private func folderLabel(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
    }

    private func rowBackground(isSelected: Bool) -> Color {
        isSelected ? Color.accentColor.opacity(0.15) : Color.clear
    }
}

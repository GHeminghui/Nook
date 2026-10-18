import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @State private var criteria = SearchService.Criteria()
    @State private var selection: Folder?
    @State private var store: LibraryStore?

    @State private var showingNewFolder = false
    @State private var newFolderName = ""
    @State private var showingNewTag = false
    @State private var newTagName = ""

    var body: some View {
        NavigationSplitView {
            FolderSidebar(selection: $selection, store: store)
                .navigationTitle("Nook")
                .safeAreaInset(edge: .bottom) {
                    SyncStatusView(enabled: ICloudSync.isEnabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button("新建文件夹", systemImage: "folder.badge.plus") {
                                newFolderName = ""
                                showingNewFolder = true
                            }
                            Button("新建标签", systemImage: "tag") {
                                newTagName = ""
                                showingNewTag = true
                            }
                        } label: {
                            Label("新建", systemImage: "plus")
                        }
                    }
                }
        } detail: {
            NavigationStack {
                Group {
                    if let store {
                        VStack(spacing: 0) {
                            SearchBar(criteria: $criteria)
                            TagFilterBar(criteria: $criteria)
                            ItemGrid(store: store, criteria: criteria, folderScope: selection) { folder in
                                selection = folder
                            }
                        }
                    } else {
                        ProgressView()
                    }
                }
                .navigationTitle(selection?.name ?? "全部资料")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        if let store {
                            ImportFlowView(store: store, target: selection)
                        }
                    }
                }
            }
        }
        .onChange(of: scenePhase) { _, phase in
            // 外部（文件 App / 预览）修改后，回到前台同步元数据与全文索引。
            guard phase == .active, let store else { return }
            store.refreshFromDisk()
        }
        .task {
            if store == nil {
                ICloudSync.migrateLegacyLibraryIfNeeded()
                let newStore = LibraryStore(context: context, rootURL: ICloudSync.libraryRoot())
                store = newStore
                try? SharedInbox.drain(into: newStore)
            }
        }
        .alert("新建文件夹", isPresented: $showingNewFolder) {
            TextField("文件夹名称", text: $newFolderName)
            Button("取消", role: .cancel) {}
            Button("创建") {
                guard let store, !newFolderName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                if let folder = try? store.createFolder(named: newFolderName, parent: selection) {
                    selection = folder
                }
            }
        } message: {
            Text("创建位置：\(newFolderParentPath)")
        }
        .alert("新建标签", isPresented: $showingNewTag) {
            TextField("标签名称", text: $newTagName)
            Button("取消", role: .cancel) {}
            Button("创建") {
                guard let store, !newTagName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                try? store.createTag(named: newTagName)
            }
        }
    }

    private var newFolderParentPath: String {
        var names: [String] = []
        var current = selection
        while let folder = current {
            names.append(folder.name)
            current = folder.parent
        }
        return names.isEmpty ? "顶层" : Array(names.reversed()).joined(separator: " / ")
    }
}

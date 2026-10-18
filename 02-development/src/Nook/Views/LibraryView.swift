import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var context
    @State private var criteria = SearchService.Criteria()
    @State private var selection: Folder?
    @State private var store: LibraryStore?

    @State private var showingNewFolder = false
    @State private var newFolderName = ""
    @State private var showingNewTag = false
    @State private var newTagName = ""

    var body: some View {
        NavigationSplitView {
            FolderSidebar(selection: $selection)
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
                            ItemGrid(store: store, criteria: criteria, folderScope: selection)
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
        .task {
            if store == nil {
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
                try? store.createFolder(named: newFolderName, parent: selection)
            }
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
}

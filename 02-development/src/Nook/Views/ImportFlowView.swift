import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ImportFlowView: View {
    let store: LibraryStore
    let target: Folder?

    @State private var showingImporter = false
    @State private var importedItems: [Item] = []
    @State private var showingTagPicker = false

    var body: some View {
        Button("导入", systemImage: "square.and.arrow.down") {
            showingImporter = true
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true
        ) { result in
            guard case .success(let urls) = result else { return }
            var newItems: [Item] = []
            for url in urls {
                let access = url.startAccessingSecurityScopedResource()
                defer { if access { url.stopAccessingSecurityScopedResource() } }
                if let item = try? store.importFile(at: url, into: target) {
                    newItems.append(item)
                }
            }
            if !newItems.isEmpty {
                importedItems = newItems
                showingTagPicker = true
            }
        }
        .sheet(isPresented: $showingTagPicker) {
            BatchTagPicker(store: store, items: importedItems)
        }
    }
}

struct BatchTagPicker: View {
    let store: LibraryStore
    let items: [Item]

    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Tag.name) private var tags: [Tag]
    @State private var selected: Set<UUID> = []

    var body: some View {
        NavigationStack {
            Group {
                if tags.isEmpty {
                    ContentUnavailableView(
                        "还没有标签",
                        systemImage: "tag.slash",
                        description: Text("先在侧栏「新建标签」，再回来批量打标签")
                    )
                } else {
                    List(tags) { tag in
                        Button {
                            if selected.contains(tag.id) {
                                selected.remove(tag.id)
                            } else {
                                selected.insert(tag.id)
                            }
                        } label: {
                            HStack {
                                Circle()
                                    .fill(Color(hex: tag.colorHex))
                                    .frame(width: 10, height: 10)
                                Text(tag.name)
                                Spacer()
                                if selected.contains(tag.id) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.tint)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle(Text(String(format: String(localized: "给 %lld 份资料打标签"), items.count)))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("跳过") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        for item in items {
                            for tag in tags where selected.contains(tag.id) {
                                try? store.addTag(tag, to: item)
                            }
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}

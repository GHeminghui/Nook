import SwiftUI
import SwiftData

struct ItemTagEditor: View {
    let store: LibraryStore
    let item: Item

    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Tag.name) private var tags: [Tag]
    @State private var selected: Set<UUID> = []
    @State private var newTagName = ""
    @State private var initialized = false

    var body: some View {
        NavigationStack {
            List {
                Section("新建标签") {
                    HStack {
                        TextField("标签名称", text: $newTagName)
                        Button("添加") { createAndSelect() }
                            .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                Section("已有标签") {
                    if tags.isEmpty {
                        Text("还没有标签，可在上方新建")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(tags) { tag in
                        Button {
                            toggle(tag)
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
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("编辑标签")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { save() }
                }
            }
            .onAppear {
                guard !initialized else { return }
                selected = Set(item.tags.map(\.id))
                initialized = true
            }
        }
    }

    private func toggle(_ tag: Tag) {
        if selected.contains(tag.id) {
            selected.remove(tag.id)
        } else {
            selected.insert(tag.id)
        }
    }

    private func createAndSelect() {
        let name = newTagName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        if let tag = try? store.createTag(named: name) {
            selected.insert(tag.id)
        }
        newTagName = ""
    }

    private func save() {
        for tag in tags {
            let attached = item.tags.contains { $0.id == tag.id }
            if selected.contains(tag.id), !attached {
                try? store.addTag(tag, to: item)
            } else if !selected.contains(tag.id), attached {
                try? store.removeTag(tag, from: item)
            }
        }
        dismiss()
    }
}

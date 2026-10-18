import SwiftUI

struct HTMLEditorView: View {
    let item: Item
    let store: LibraryStore

    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var loaded = false
    @State private var saveError: String?

    private var url: URL { store.absoluteURL(for: item) }

    var body: some View {
        NavigationStack {
            TextEditor(text: $text)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 8)
                .navigationTitle("编辑 HTML")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("保存") { save() }
                    }
                }
                .onAppear {
                    guard !loaded else { return }
                    text = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
                    loaded = true
                }
                .alert("保存失败", isPresented: Binding(
                    get: { saveError != nil },
                    set: { if !$0 { saveError = nil } }
                )) {
                    Button("知道了", role: .cancel) { saveError = nil }
                } message: {
                    Text(saveError ?? "")
                }
        }
    }

    private func save() {
        do {
            try text.write(to: url, atomically: true, encoding: .utf8)
            store.markEdited(item)
            dismiss()
        } catch {
            saveError = error.localizedDescription
        }
    }
}

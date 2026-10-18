import SwiftUI

struct PreviewContainer: View {
    let item: Item
    let store: LibraryStore

    private var url: URL { store.absoluteURL(for: item) }

    @State private var activeSheet: PreviewSheet?

    private enum PreviewSheet: String, Identifiable {
        case share
        case tags
        case move
        case htmlEditor
        case imageMarkup

        var id: String { rawValue }
    }

    private var editorSheet: PreviewSheet? {
        switch item.kind {
        case .pdf: return nil
        case .html: return .htmlEditor
        case .image: return .imageMarkup
        case .other: return nil
        }
    }

    private var previewIdentity: String {
        "\(item.kindRaw)-\(item.modifiedAt.timeIntervalSince1970)"
    }

    var body: some View {
        Group {
            switch item.kind {
            case .pdf: QuickLookPreview(url: url)
            case .image: ImagePreview(url: url)
            case .html: HTMLPreview(url: url)
            case .other: QuickLookPreview(url: url)
            }
        }
        .id(previewIdentity)
        .navigationTitle(item.fileName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if let editorSheet {
                    Button {
                        activeSheet = editorSheet
                    } label: {
                        Label("编辑", systemImage: "pencil")
                    }
                }
                Menu {
                    Button("编辑标签", systemImage: "tag") { activeSheet = .tags }
                    Button("移动到…", systemImage: "folder") { activeSheet = .move }
                } label: {
                    Label("更多", systemImage: "ellipsis.circle")
                }
                Button {
                    activeSheet = .share
                } label: {
                    Label("分享", systemImage: "square.and.arrow.up")
                }
                Button {
                    PrintService.printItem(url: url)
                } label: {
                    Label("打印", systemImage: "printer")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .share:
                ShareSheet(items: [url])
            case .tags:
                ItemTagEditor(store: store, item: item)
            case .move:
                MoveItemSheet(store: store, item: item)
            case .htmlEditor:
                HTMLEditorView(item: item, store: store)
            case .imageMarkup:
                ImageMarkupView(item: item, store: store)
            }
        }
        .overlay(alignment: .bottom) {
            if item.kind == .html {
                Text("HTML 若引用外部资源，部分内容可能无法显示")
                    .font(.footnote)
                    .padding(6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.bottom, 8)
            }
        }
    }
}

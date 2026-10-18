import SwiftUI

struct PreviewContainer: View {
    let item: Item
    let store: LibraryStore

    private var url: URL { store.absoluteURL(for: item) }

    @State private var showingShare = false
    @State private var showingTags = false
    @State private var showingMove = false

    var body: some View {
        Group {
            switch item.kind {
            case .pdf: PDFPreview(url: url)
            case .image: ImagePreview(url: url)
            case .html: HTMLPreview(url: url)
            case .other: QuickLookPreview(url: url)
            }
        }
        .navigationTitle(item.fileName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    Button("编辑标签", systemImage: "tag") { showingTags = true }
                    Button("移动到…", systemImage: "folder") { showingMove = true }
                } label: {
                    Label("更多", systemImage: "ellipsis.circle")
                }
                Button {
                    showingShare = true
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
        .sheet(isPresented: $showingShare) {
            ShareSheet(items: [url])
        }
        .sheet(isPresented: $showingTags) {
            ItemTagEditor(store: store, item: item)
        }
        .sheet(isPresented: $showingMove) {
            MoveItemSheet(store: store, item: item)
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

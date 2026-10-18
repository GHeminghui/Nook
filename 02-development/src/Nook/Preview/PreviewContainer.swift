import SwiftUI

struct PreviewContainer: View {
    let item: Item
    let url: URL

    @State private var showingShare = false

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

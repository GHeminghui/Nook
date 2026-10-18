import Foundation
import SwiftData

@MainActor
enum IndexingPipeline {
    static func index(item: Item, store: LibraryStore) {
        let url = store.absoluteURL(for: item)
        item.textContent = TextExtractor.extract(from: url, kind: item.kind)
        item.indexState = "indexed"
        try? store.context.save()
    }
}

import Foundation
import SwiftData

enum SearchService {
    struct Criteria: Equatable {
        var text: String = ""
        var folderScope: UUID?
        var tagIDs: Set<UUID> = []
        var matchAllTags: Bool = false
    }

    struct Snapshot {
        let id: UUID
        let folderID: UUID
        let folderAncestors: [UUID]
        let fileName: String
        let textContent: String
        let tagIDs: [UUID]
    }

    static func matches(_ s: Snapshot, _ c: Criteria) -> Bool {
        if !c.text.isEmpty {
            let q = c.text.lowercased()
            let hit = s.fileName.lowercased().contains(q) || s.textContent.lowercased().contains(q)
            if !hit { return false }
        }
        if let scope = c.folderScope, !s.folderAncestors.contains(scope) { return false }
        if !c.tagIDs.isEmpty {
            let set = Set(s.tagIDs)
            if c.matchAllTags {
                if !c.tagIDs.isSubset(of: set) { return false }
            } else {
                if c.tagIDs.isDisjoint(with: set) { return false }
            }
        }
        return true
    }

    @MainActor
    static func search(_ criteria: Criteria, store: LibraryStore) -> [Item] {
        let all = (try? store.context.fetch(FetchDescriptor<Item>())) ?? []
        let matched = all.filter { item in
            let snapshot = Snapshot(
                id: item.id,
                folderID: item.folder?.id ?? UUID(),
                folderAncestors: store.ancestors(of: item.folder),
                fileName: item.fileName,
                textContent: item.textContent,
                tagIDs: item.tags.map(\.id)
            )
            return matches(snapshot, criteria)
        }
        return matched.sorted { $0.importedAt > $1.importedAt }
    }
}

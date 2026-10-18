import Foundation
import SwiftData

@Model final class Folder {
    @Attribute(.unique) var id: UUID
    var name: String
    var sortOrder: Int
    var createdAt: Date
    var parent: Folder?
    @Relationship(deleteRule: .cascade, inverse: \Folder.parent) var children: [Folder] = []
    @Relationship(deleteRule: .cascade, inverse: \Item.folder) var items: [Item] = []

    init(id: UUID = UUID(), name: String, sortOrder: Int = 0, parent: Folder? = nil) {
        self.id = id
        self.name = name
        self.sortOrder = sortOrder
        self.createdAt = Date()
        self.parent = parent
    }

    var sortedChildren: [Folder] {
        children.sorted { ($0.sortOrder, $0.name) < ($1.sortOrder, $1.name) }
    }

    var optionalChildren: [Folder]? {
        sortedChildren.isEmpty ? nil : sortedChildren
    }
}

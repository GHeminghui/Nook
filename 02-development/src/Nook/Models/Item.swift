import Foundation
import SwiftData

@Model final class Item {
    @Attribute(.unique) var id: UUID
    var fileName: String
    var relativePath: String
    var kindRaw: String
    var size: Int
    var importedAt: Date
    var modifiedAt: Date
    var textContent: String
    var indexState: String
    var sortOrder: Int = 0
    var folder: Folder?
    @Relationship(inverse: \Tag.items) var tags: [Tag] = []

    init(id: UUID = UUID(), fileName: String, relativePath: String, kind: ItemKind, size: Int, sortOrder: Int = 0) {
        self.id = id
        self.fileName = fileName
        self.relativePath = relativePath
        self.kindRaw = kind.rawValue
        self.size = size
        self.importedAt = Date()
        self.modifiedAt = Date()
        self.textContent = ""
        self.indexState = "pending"
        self.sortOrder = sortOrder
    }

    var kind: ItemKind { ItemKind(rawValue: kindRaw) ?? .other }
}

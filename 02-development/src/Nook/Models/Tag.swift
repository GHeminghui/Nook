import Foundation
import SwiftData

@Model final class Tag {
    @Attribute(.unique) var id: UUID
    var name: String
    var colorHex: String
    var items: [Item] = []

    init(id: UUID = UUID(), name: String, colorHex: String = "#3B6CF6") {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }
}

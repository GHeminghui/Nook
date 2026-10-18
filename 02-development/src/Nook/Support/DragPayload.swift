import Foundation

enum DragPayload {
    enum Target: Equatable {
        case item(UUID)
        case folder(UUID)
    }

    static func item(_ id: UUID) -> String {
        "item:\(id.uuidString)"
    }

    static func folder(_ id: UUID) -> String {
        "folder:\(id.uuidString)"
    }

    static func parse(_ raw: String) -> Target? {
        let parts = raw.split(separator: ":", maxSplits: 1)
        guard parts.count == 2, let id = UUID(uuidString: String(parts[1])) else { return nil }
        switch parts[0] {
        case "item": return .item(id)
        case "folder": return .folder(id)
        default: return nil
        }
    }
}

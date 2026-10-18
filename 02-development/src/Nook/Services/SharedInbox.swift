import Foundation
import SwiftData

/// 读取分享扩展写入 App Group 的 Inbox，并导入到「未分类」。
@MainActor
enum SharedInbox {
    static let appGroupID = "group.com.hmh.app"

    static var inboxURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent("Inbox", isDirectory: true)
    }

    static func drain(into store: LibraryStore) throws {
        guard let inbox = inboxURL,
              FileManager.default.fileExists(atPath: inbox.path) else { return }

        let files = (try? FileManager.default.contentsOfDirectory(
            at: inbox,
            includingPropertiesForKeys: nil
        )) ?? []
        guard !files.isEmpty else { return }

        let folder = try unfiledFolder(in: store)
        for file in files {
            _ = try? store.importFile(at: file, into: folder)
            try? FileManager.default.removeItem(at: file)
        }
    }

    private static func unfiledFolder(in store: LibraryStore) throws -> Folder {
        let name = "未分类"
        let descriptor = FetchDescriptor<Folder>(predicate: #Predicate { $0.name == name })
        if let existing = try store.context.fetch(descriptor).first {
            return existing
        }
        return try store.createFolder(named: name, parent: nil)
    }
}

import Testing
import SwiftData
import Foundation
@testable import Nook

@MainActor
@Suite struct LibraryStoreTests {
    private let container: ModelContainer
    private let store: LibraryStore

    init() throws {
        let cfg = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        container = try ModelContainer(for: Folder.self, Item.self, Tag.self, configurations: cfg)
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        store = LibraryStore(context: container.mainContext, rootURL: root)
    }

    @Test func createsNestedFolders() throws {
        let a = try store.createFolder(named: "数学", parent: nil)
        let b = try store.createFolder(named: "高一", parent: a)
        #expect(b.parent?.id == a.id)
    }

    @Test func importFileWritesToDiskAndRegisters() throws {
        let src = FileManager.default.temporaryDirectory.appendingPathComponent("习题.pdf")
        try Data("hello".utf8).write(to: src)
        let folder = try store.createFolder(named: "数学", parent: nil)
        let item = try store.importFile(at: src, into: folder)
        #expect(item.fileName == "习题.pdf")
        #expect(FileManager.default.fileExists(atPath: store.absoluteURL(for: item).path))
    }

    @Test func renameItemKeepsExtensionAndMovesFile() throws {
        let folder = try store.createFolder(named: "数学", parent: nil)
        let src = FileManager.default.temporaryDirectory.appendingPathComponent("习题.pdf")
        try Data("x".utf8).write(to: src)
        let item = try store.importFile(at: src, into: folder)
        let oldURL = store.absoluteURL(for: item)

        try store.renameItem(item, to: "第一次月考")

        #expect(item.fileName == "第一次月考.pdf")
        #expect(!FileManager.default.fileExists(atPath: oldURL.path))
        #expect(FileManager.default.fileExists(atPath: store.absoluteURL(for: item).path))
        #expect(store.relativePath(of: store.absoluteURL(for: item)) == "数学/第一次月考.pdf")
    }

    @Test func renameItemDeduplicatesInSameFolder() throws {
        let folder = try store.createFolder(named: "数学", parent: nil)
        for name in ["a.pdf", "b.pdf"] {
            let src = FileManager.default.temporaryDirectory.appendingPathComponent(name)
            try Data("x".utf8).write(to: src)
            _ = try store.importFile(at: src, into: folder)
        }
        let items = try container.mainContext.fetch(FetchDescriptor<Item>())
        let target = try #require(items.first { $0.fileName == "b.pdf" })

        try store.renameItem(target, to: "a")

        #expect(target.fileName == "a (1).pdf")
    }

    @Test func deduplicatesOnImport() throws {
        let folder = try store.createFolder(named: "数学", parent: nil)
        let src = FileManager.default.temporaryDirectory.appendingPathComponent("习题.pdf")
        try Data("x".utf8).write(to: src)
        _ = try store.importFile(at: src, into: folder)
        let second = try store.importFile(at: src, into: folder)
        #expect(second.fileName == "习题 (1).pdf")
    }

    @Test func taggingAndFetch() throws {
        let folder = try store.createFolder(named: "数学", parent: nil)
        let src = FileManager.default.temporaryDirectory.appendingPathComponent("a.pdf")
        try Data("x".utf8).write(to: src)
        let item = try store.importFile(at: src, into: folder)
        let tag = try store.createTag(named: "易错")
        try store.addTag(tag, to: item)
        #expect(item.tags.contains { $0.id == tag.id })

        try store.removeTag(tag, from: item)
        #expect(item.tags.isEmpty)
    }

    @Test func movingItemUpdatesDiskAndFolder() throws {
        let math = try store.createFolder(named: "数学", parent: nil)
        let chinese = try store.createFolder(named: "语文", parent: nil)
        let src = FileManager.default.temporaryDirectory.appendingPathComponent("习题.pdf")
        try Data("x".utf8).write(to: src)
        let item = try store.importFile(at: src, into: math)
        let oldURL = store.absoluteURL(for: item)

        try store.moveItem(item, to: chinese)

        #expect(item.folder?.id == chinese.id)
        #expect(!FileManager.default.fileExists(atPath: oldURL.path))
        #expect(FileManager.default.fileExists(atPath: store.absoluteURL(for: item).path))
        #expect(store.absoluteURL(for: item).deletingLastPathComponent().lastPathComponent == "语文")
    }

    @Test func renamingFolderUpdatesChildItemPaths() throws {
        let parent = try store.createFolder(named: "数学", parent: nil)
        let child = try store.createFolder(named: "函数", parent: parent)
        let src = FileManager.default.temporaryDirectory.appendingPathComponent("讲义.html")
        try Data("<html>函数</html>".utf8).write(to: src)
        let item = try store.importFile(at: src, into: child)
        let oldURL = store.absoluteURL(for: item)

        try store.renameFolder(parent, to: "数学-新")

        #expect(parent.name == "数学-新")
        #expect(item.relativePath.hasPrefix("数学-新/函数/"))
        #expect(!FileManager.default.fileExists(atPath: oldURL.path))
        #expect(FileManager.default.fileExists(atPath: store.absoluteURL(for: item).path))
    }

    @Test func movingFolderUpdatesDescendantPaths() throws {
        let math = try store.createFolder(named: "数学", parent: nil)
        let functions = try store.createFolder(named: "函数", parent: math)
        let archive = try store.createFolder(named: "归档", parent: nil)
        let src = FileManager.default.temporaryDirectory.appendingPathComponent("讲义.html")
        try Data("<html>函数</html>".utf8).write(to: src)
        let item = try store.importFile(at: src, into: functions)
        let oldURL = store.absoluteURL(for: item)

        try store.moveFolder(functions, to: archive)

        #expect(functions.parent?.id == archive.id)
        #expect(item.relativePath.hasPrefix("归档/函数/"))
        #expect(!FileManager.default.fileExists(atPath: oldURL.path))
        #expect(FileManager.default.fileExists(atPath: store.absoluteURL(for: item).path))
    }

    @Test func preventsMovingFolderIntoItsDescendant() throws {
        let parent = try store.createFolder(named: "数学", parent: nil)
        let child = try store.createFolder(named: "函数", parent: parent)

        try store.moveFolder(parent, to: child)

        #expect(parent.parent == nil)
        #expect(child.parent?.id == parent.id)
    }

    @Test func deletingEmptyFolderSucceeds() throws {
        let folder = try store.createFolder(named: "临时", parent: nil)

        try store.deleteFolder(folder)

        let remaining = (try? store.context.fetch(FetchDescriptor<Folder>())) ?? []
        #expect(!remaining.contains { $0.id == folder.id })
    }

    @Test func refusesDeletingFolderWithDirectItems() throws {
        let folder = try store.createFolder(named: "临时", parent: nil)
        let item = try importHTML(named: "a.html", into: folder)
        let fileURL = store.absoluteURL(for: item)

        #expect(throws: LibraryStoreError.self) {
            try store.deleteFolder(folder)
        }

        let remaining = (try? store.context.fetch(FetchDescriptor<Folder>())) ?? []
        #expect(remaining.contains { $0.id == folder.id })
        #expect(FileManager.default.fileExists(atPath: fileURL.path))
    }

    @Test func refusesDeletingFolderWithNestedItems() throws {
        let parent = try store.createFolder(named: "数学", parent: nil)
        let child = try store.createFolder(named: "函数", parent: parent)
        let item = try importHTML(named: "讲义.html", into: child)
        let fileURL = store.absoluteURL(for: item)

        #expect(throws: LibraryStoreError.self) {
            try store.deleteFolder(parent)
        }

        let remaining = (try? store.context.fetch(FetchDescriptor<Folder>())) ?? []
        #expect(remaining.contains { $0.id == parent.id })
        #expect(remaining.contains { $0.id == child.id })
        #expect(FileManager.default.fileExists(atPath: fileURL.path))
    }

    @Test func reordersFoldersAmongSiblings() throws {
        let a = try store.createFolder(named: "A", parent: nil)
        _ = try store.createFolder(named: "B", parent: nil)
        let c = try store.createFolder(named: "C", parent: nil)

        try store.reorderFolder(c, relativeTo: a)

        let roots = try store.context.fetch(FetchDescriptor<Folder>())
            .filter { $0.parent == nil }
            .sorted { $0.sortOrder < $1.sortOrder }
        #expect(roots.map(\.name) == ["C", "A", "B"])
        #expect(roots.map(\.sortOrder) == [0, 1, 2])
    }

    @Test func reordersItemsAmongSiblings() throws {
        let folder = try store.createFolder(named: "数学", parent: nil)
        let a = try importHTML(named: "a.html", into: folder)
        let b = try importHTML(named: "b.html", into: folder)
        let c = try importHTML(named: "c.html", into: folder)
        a.importedAt = Date(timeIntervalSince1970: 100)
        b.importedAt = Date(timeIntervalSince1970: 200)
        c.importedAt = Date(timeIntervalSince1970: 300)
        try store.context.save()

        try store.reorderItem(a, relativeTo: c)

        let ordered = try store.context.fetch(FetchDescriptor<Item>())
            .sorted { $0.sortOrder < $1.sortOrder }
        #expect(ordered.map(\.fileName) == ["a.html", "c.html", "b.html"])
        #expect(ordered.map(\.sortOrder) == [0, 1, 2])
    }

    @Test func reordersItemAcrossFolders() throws {
        let math = try store.createFolder(named: "数学", parent: nil)
        let chinese = try store.createFolder(named: "语文", parent: nil)
        let source = try importHTML(named: "源.html", into: math)
        let target = try importHTML(named: "目标.html", into: chinese)

        try store.reorderItem(source, relativeTo: target)

        #expect(source.folder?.id == chinese.id)
        #expect(source.sortOrder < target.sortOrder)
        #expect(FileManager.default.fileExists(atPath: store.absoluteURL(for: source).path))
    }

    private func importHTML(named name: String, into folder: Folder) throws -> Item {
        let src = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        try Data("<html>\(name)</html>".utf8).write(to: src)
        return try store.importFile(at: src, into: folder)
    }

    @Test func markEditedRefreshesMetadataAndIndex() throws {
        let folder = try store.createFolder(named: "临时", parent: nil)
        let item = try importHTML(named: "讲义.html", into: folder)
        let oldModified = item.modifiedAt

        try "<html><body>更新后的内容</body></html>"
            .write(to: store.absoluteURL(for: item), atomically: true, encoding: .utf8)
        store.markEdited(item)

        #expect(item.textContent.contains("更新后的内容"))
        #expect(item.modifiedAt >= oldModified)
        #expect(item.size > 0)
    }

    @Test func refreshFromDiskPicksUpExternalChanges() throws {
        let folder = try store.createFolder(named: "临时", parent: nil)
        let item = try importHTML(named: "外部修改.html", into: folder)
        let url = store.absoluteURL(for: item)

        try "<html><body>外部写入的新内容，长度更长一些</body></html>"
            .write(to: url, atomically: true, encoding: .utf8)
        let newModified = Date().addingTimeInterval(60)
        try FileManager.default.setAttributes(
            [.modificationDate: newModified],
            ofItemAtPath: url.path
        )

        let changed = store.refreshFromDisk()
        #expect(changed == 1)
        #expect(item.textContent.contains("外部写入的新内容"))
        #expect(abs(item.modifiedAt.timeIntervalSince(newModified)) < 2)
        #expect(store.refreshFromDisk() == 0)
    }
}

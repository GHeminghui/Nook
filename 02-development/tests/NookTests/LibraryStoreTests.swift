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
    }
}

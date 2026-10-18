import Testing
import SwiftData
import Foundation
@testable import Nook

@MainActor
@Suite struct IntegrationTests {
    @Test func importThenSearchFindsByContent() throws {
        let cfg = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try ModelContainer(for: Folder.self, Item.self, Tag.self, configurations: cfg)
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let store = LibraryStore(context: container.mainContext, rootURL: root)

        let src = root.appendingPathComponent("函数练习.html")
        try "<html><body>二次函数 与 图像</body></html>".write(to: src, atomically: true, encoding: .utf8)

        let folder = try store.createFolder(named: "数学", parent: nil)
        let item = try store.importFile(at: src, into: folder)
        IndexingPipeline.index(item: item, store: store)

        var c = SearchService.Criteria()
        c.text = "二次函数"
        let results = SearchService.search(c, store: store)
        #expect(results.contains { $0.id == item.id })
    }

    @Test func folderScopeOnlyReturnsDirectItems() throws {
        let cfg = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try ModelContainer(for: Folder.self, Item.self, Tag.self, configurations: cfg)
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let store = LibraryStore(context: container.mainContext, rootURL: root)

        let math = try store.createFolder(named: "数学", parent: nil)
        let chinese = try store.createFolder(named: "语文", parent: nil)
        let nested = try store.createFolder(named: "函数", parent: math)

        let nestedSrc = root.appendingPathComponent("嵌套讲义.html")
        try "<html><body>函数</body></html>".write(to: nestedSrc, atomically: true, encoding: .utf8)
        _ = try store.importFile(at: nestedSrc, into: nested)

        let directSrc = root.appendingPathComponent("直属讲义.html")
        try "<html><body>集合</body></html>".write(to: directSrc, atomically: true, encoding: .utf8)
        let direct = try store.importFile(at: directSrc, into: math)

        let chineseSrc = root.appendingPathComponent("作文.html")
        try "<html><body>作文</body></html>".write(to: chineseSrc, atomically: true, encoding: .utf8)
        _ = try store.importFile(at: chineseSrc, into: chinese)

        var c = SearchService.Criteria()
        c.folderScope = math.id
        let results = SearchService.search(c, store: store)
        #expect(results.count == 1)
        #expect(results.first?.id == direct.id)
    }
}

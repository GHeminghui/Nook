import Foundation
import SwiftData

@MainActor
final class LibraryStore {
    let context: ModelContext
    let rootURL: URL
    private let fm = FileManager.default

    init(context: ModelContext, rootURL: URL) {
        self.context = context
        self.rootURL = rootURL
        try? fm.createDirectory(at: rootURL, withIntermediateDirectories: true)
    }

    // MARK: - Folders

    /// 返回自身与所有上级文件夹的 ID（顺序：自身 → 根）。
    func ancestors(of folder: Folder?) -> [UUID] {
        var result: [UUID] = []
        var current = folder
        while let f = current {
            result.append(f.id)
            current = f.parent
        }
        return result
    }

    func folderNames(of folder: Folder?) -> [String] {
        var names: [String] = []
        var current = folder
        while let f = current {
            names.append(f.name)
            current = f.parent
        }
        return names.reversed()
    }

    func folderURL(for folder: Folder) -> URL {
        folderNames(of: folder).reduce(rootURL) { $0.appendingPathComponent($1) }
    }

    @discardableResult
    func createFolder(named raw: String, parent: Folder?) throws -> Folder {
        let name = PathSanitizer.sanitize(raw)
        let folder = Folder(name: name, parent: parent)
        context.insert(folder)
        try fm.createDirectory(at: folderURL(for: folder), withIntermediateDirectories: true)
        try context.save()
        return folder
    }

    func renameFolder(_ folder: Folder, to raw: String) throws {
        let oldURL = folderURL(for: folder)
        folder.name = PathSanitizer.sanitize(raw)
        let newURL = folderURL(for: folder)
        if oldURL != newURL, fm.fileExists(atPath: oldURL.path) {
            try fm.moveItem(at: oldURL, to: newURL)
        }
        try context.save()
    }

    func deleteFolder(_ folder: Folder) throws {
        let url = folderURL(for: folder)
        if fm.fileExists(atPath: url.path) {
            try fm.removeItem(at: url)
        }
        context.delete(folder)
        try context.save()
    }

    // MARK: - Items

    @discardableResult
    func importFile(at source: URL, into folder: Folder?) throws -> Item {
        let destDir: URL
        if let folder {
            destDir = folderURL(for: folder)
            try fm.createDirectory(at: destDir, withIntermediateDirectories: true)
        } else {
            destDir = rootURL
            try fm.createDirectory(at: destDir, withIntermediateDirectories: true)
        }

        let existing = Set((try? fm.contentsOfDirectory(atPath: destDir.path)) ?? [])
        let fileName = NameDeduper.uniqueName(source.lastPathComponent, existing: existing)
        let dest = destDir.appendingPathComponent(fileName)

        if source.standardizedFileURL == dest.standardizedFileURL {
            // 已在该位置，无需复制。
        } else {
            if fm.fileExists(atPath: dest.path) { try fm.removeItem(at: dest) }
            try fm.copyItem(at: source, to: dest)
        }

        let attrs = try fm.attributesOfItem(atPath: dest.path)
        let size = (attrs[.size] as? Int) ?? 0
        let item = Item(
            fileName: fileName,
            relativePath: relativePath(of: dest),
            kind: ItemKind.from(url: dest),
            size: size
        )
        item.folder = folder
        context.insert(item)
        try context.save()
        IndexingPipeline.index(item: item, store: self)
        return item
    }

    func renameItem(_ item: Item, to raw: String) throws {
        let oldURL = absoluteURL(for: item)
        let dir = oldURL.deletingLastPathComponent()
        let existing = Set((try? fm.contentsOfDirectory(atPath: dir.path)) ?? [])
        let desired = PathSanitizer.sanitize(raw)
        let fileName = NameDeduper.uniqueName(desired, existing: existing)
        let newURL = dir.appendingPathComponent(fileName)
        if oldURL != newURL, fm.fileExists(atPath: oldURL.path) {
            try fm.moveItem(at: oldURL, to: newURL)
        }
        item.fileName = fileName
        item.relativePath = relativePath(of: newURL)
        item.kindRaw = ItemKind.from(url: newURL).rawValue
        item.modifiedAt = Date()
        try context.save()
    }

    func deleteItem(_ item: Item) throws {
        let url = absoluteURL(for: item)
        if fm.fileExists(atPath: url.path) {
            try fm.removeItem(at: url)
        }
        context.delete(item)
        try context.save()
    }

    func moveItem(_ item: Item, to folder: Folder?) throws {
        let sourceURL = absoluteURL(for: item)
        let destDir = folder.map { folderURL(for: $0) } ?? rootURL
        try fm.createDirectory(at: destDir, withIntermediateDirectories: true)

        let sameDirectory = sourceURL.deletingLastPathComponent().standardizedFileURL
            == destDir.standardizedFileURL
        if sameDirectory {
            item.folder = folder
            try context.save()
            return
        }

        let existing = Set((try? fm.contentsOfDirectory(atPath: destDir.path)) ?? [])
        let fileName = NameDeduper.uniqueName(item.fileName, existing: existing)
        let destURL = destDir.appendingPathComponent(fileName)

        if fm.fileExists(atPath: sourceURL.path) {
            try fm.moveItem(at: sourceURL, to: destURL)
        }

        item.fileName = fileName
        item.relativePath = relativePath(of: destURL)
        item.folder = folder
        item.modifiedAt = Date()
        try context.save()
    }

    func absoluteURL(for item: Item) -> URL {
        rootURL.appendingPathComponent(item.relativePath)
    }

    func relativePath(of url: URL) -> String {
        let rootPath = rootURL.standardizedFileURL.path
        let fullPath = url.standardizedFileURL.path
        if fullPath.hasPrefix(rootPath + "/") {
            return String(fullPath.dropFirst(rootPath.count + 1))
        }
        return url.lastPathComponent
    }

    // MARK: - Tags

    @discardableResult
    func createTag(named raw: String, colorHex: String = "#3B6CF6") throws -> Tag {
        let tag = Tag(name: PathSanitizer.sanitize(raw), colorHex: colorHex)
        context.insert(tag)
        try context.save()
        return tag
    }

    func addTag(_ tag: Tag, to item: Item) throws {
        if !item.tags.contains(where: { $0.id == tag.id }) {
            item.tags.append(tag)
        }
        try context.save()
    }

    func removeTag(_ tag: Tag, from item: Item) throws {
        item.tags.removeAll { $0.id == tag.id }
        try context.save()
    }

    func deleteTag(_ tag: Tag) throws {
        context.delete(tag)
        try context.save()
    }
}

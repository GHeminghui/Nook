import Foundation
import SwiftData

enum LibraryStoreError: LocalizedError {
    case folderNotEmpty

    var errorDescription: String? {
        "文件夹或其子文件夹内还有文件，无法删除"
    }
}

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
        let name = PathSanitizer.sanitize(raw)
        guard name != folder.name else { return }

        let oldURL = folderURL(for: folder)
        let parentURL = oldURL.deletingLastPathComponent()
        let existing = Set((try? fm.contentsOfDirectory(atPath: parentURL.path)) ?? [])
            .subtracting([folder.name])
        let uniqueName = NameDeduper.uniqueName(name, existing: existing)

        folder.name = uniqueName
        let newURL = folderURL(for: folder)
        if oldURL != newURL, fm.fileExists(atPath: oldURL.path) {
            try fm.moveItem(at: oldURL, to: newURL)
        }
        refreshRelativePaths(in: folder)
        try context.save()
    }

    func moveFolder(_ folder: Folder, to newParent: Folder?) throws {
        guard folder.parent?.id != newParent?.id else { return }
        if let newParent, ancestors(of: newParent).contains(folder.id) { return }

        let oldURL = folderURL(for: folder)
        let destParentURL = newParent.map { folderURL(for: $0) } ?? rootURL
        try fm.createDirectory(at: destParentURL, withIntermediateDirectories: true)

        let existing = Set((try? fm.contentsOfDirectory(atPath: destParentURL.path)) ?? [])
        let uniqueName = NameDeduper.uniqueName(folder.name, existing: existing)

        folder.name = uniqueName
        folder.parent = newParent
        let newURL = destParentURL.appendingPathComponent(uniqueName)

        if fm.fileExists(atPath: oldURL.path) {
            try fm.moveItem(at: oldURL, to: newURL)
        }
        refreshRelativePaths(in: folder)
        try context.save()
    }

    func deleteFolder(_ folder: Folder) throws {
        guard !folderContainsItems(folder) else {
            throw LibraryStoreError.folderNotEmpty
        }

        let url = folderURL(for: folder)
        if fm.fileExists(atPath: url.path) {
            try fm.removeItem(at: url)
        }
        context.delete(folder)
        try context.save()
    }

    func folderContainsItems(_ folder: Folder) -> Bool {
        if !folder.items.isEmpty { return true }
        return folder.children.contains { folderContainsItems($0) }
    }

    private func refreshRelativePaths(in folder: Folder) {
        let base = folderURL(for: folder)
        for item in folder.items {
            item.relativePath = relativePath(of: base.appendingPathComponent(item.fileName))
        }
        for child in folder.children {
            refreshRelativePaths(in: child)
        }
    }

    func reorderFolder(_ folder: Folder, relativeTo target: Folder, placeAfter: Bool = false) throws {
        guard folder.id != target.id, folder.parent?.id == target.parent?.id else { return }

        var ordered = folderSiblings(of: folder.parent)
        ordered.removeAll { $0.id == folder.id }
        guard let targetIndex = ordered.firstIndex(where: { $0.id == target.id }) else { return }
        ordered.insert(folder, at: targetIndex + (placeAfter ? 1 : 0))

        for (index, sibling) in ordered.enumerated() {
            sibling.sortOrder = index
        }
        try context.save()
    }

    func reorderItem(_ item: Item, relativeTo target: Item, placeAfter: Bool = false) throws {
        guard item.id != target.id else { return }

        if item.folder?.id != target.folder?.id {
            try moveItem(item, to: target.folder)
        }

        var ordered = itemSiblings(in: target.folder)
        ordered.removeAll { $0.id == item.id }
        guard let targetIndex = ordered.firstIndex(where: { $0.id == target.id }) else { return }
        ordered.insert(item, at: targetIndex + (placeAfter ? 1 : 0))

        for (index, sibling) in ordered.enumerated() {
            sibling.sortOrder = index
        }
        try context.save()
    }

    private func folderSiblings(of parent: Folder?) -> [Folder] {
        let all = (try? context.fetch(FetchDescriptor<Folder>())) ?? []
        return all
            .filter { $0.parent?.id == parent?.id }
            .sorted { lhs, rhs in
                if lhs.sortOrder != rhs.sortOrder { return lhs.sortOrder < rhs.sortOrder }
                return lhs.name < rhs.name
            }
    }

    private func itemSiblings(in folder: Folder?) -> [Item] {
        let all = (try? context.fetch(FetchDescriptor<Item>())) ?? []
        return all
            .filter { $0.folder?.id == folder?.id }
            .sorted { lhs, rhs in
                if lhs.sortOrder != rhs.sortOrder { return lhs.sortOrder < rhs.sortOrder }
                return lhs.importedAt > rhs.importedAt
            }
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

    /// 重命名资料文件，保留原扩展名并避免与同目录文件重名。
    func renameItem(_ item: Item, to raw: String) throws {
        let baseName = PathSanitizer.sanitize(raw)
        let ext = (item.fileName as NSString).pathExtension
        let desired: String
        if !ext.isEmpty, baseName.lowercased().hasSuffix("." + ext.lowercased()) {
            desired = baseName
        } else {
            desired = ext.isEmpty ? baseName : "\(baseName).\(ext)"
        }
        guard desired != item.fileName else { return }

        let oldURL = absoluteURL(for: item)
        let dir = oldURL.deletingLastPathComponent()
        let existing = Set((try? fm.contentsOfDirectory(atPath: dir.path)) ?? [])
            .subtracting([item.fileName])
        let fileName = NameDeduper.uniqueName(desired, existing: existing)
        let newURL = dir.appendingPathComponent(fileName)

        if fm.fileExists(atPath: oldURL.path) {
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

    /// 文件被 App 内编辑器写回后，刷新大小、修改时间与全文索引。
    func markEdited(_ item: Item, reindex: Bool = true) {
        let url = absoluteURL(for: item)
        if let attrs = try? fm.attributesOfItem(atPath: url.path) {
            item.size = (attrs[.size] as? Int) ?? item.size
        }
        item.modifiedAt = Date()
        try? context.save()
        if reindex {
            IndexingPipeline.index(item: item, store: self)
        }
    }

    /// 文件在「文件」App / 预览等外部被修改后，回到前台时同步元数据与全文索引。
    /// 返回本次发现变化的文件数。
    @discardableResult
    func refreshFromDisk() -> Int {
        let items = (try? context.fetch(FetchDescriptor<Item>())) ?? []
        var changed = 0

        for item in items {
            let url = absoluteURL(for: item)
            guard let attrs = try? fm.attributesOfItem(atPath: url.path) else { continue }

            let size = (attrs[.size] as? Int) ?? item.size
            let modified = (attrs[.modificationDate] as? Date) ?? item.modifiedAt
            guard size != item.size || abs(modified.timeIntervalSince(item.modifiedAt)) > 1 else {
                continue
            }

            item.size = size
            item.modifiedAt = modified
            IndexingPipeline.index(item: item, store: self)
            changed += 1
        }

        if changed > 0 {
            try? context.save()
        }
        return changed
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

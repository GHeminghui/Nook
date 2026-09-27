# Nook v1 实施计划（Implementation Plan）

> **面向执行者**：REQUIRED SUB-SKILL：使用 `superpowers:subagent-driven-development`（推荐）或 `superpowers:executing-plans` 逐任务执行本计划。步骤用 `- [ ]` 跟踪进度。
>
> 本项目遵循四阶段流程，产物路径以 `PROJECT_STATE.json` 为准（本计划落在 `02-development/plan.md`）。

**目标**：交付 iPad 本地教学资料库 App **v1** —— 支持多级文件夹、标签、全文检索、PDF/图片/HTML 预览、系统分享与打印、分享扩展收资料、iCloud 备份。

**架构**：SwiftUI（iPadOS 17+）应用；元数据用 **SwiftData**；文件按**真实目录**存于 App 容器；预览用 **PDFKit / WKWebView / QuickLook**；分享用 **UIActivityViewController**；收资料用 **Share Extension**；同步用 **iCloud Documents**。

**技术栈**：Xcode 27 / Swift 6.4 / iOS SDK 27 / 最低 iPadOS 17；SwiftUI、SwiftData、PDFKit、WebKit、QuickLook、UniformTypeIdentifiers。

**与设计文档的偏差**：v1 的全文检索改用「SwiftData 文本字段 + 谓词/内存过滤」，替代 `tech-design.md` 中的 SQLite FTS5。理由与后果见 [ADR-001](../docs/adr/001-fulltext-search-implementation.md)。

---

## 文件结构

```
02-development/
  plan.md
  src/                      # 全部源码
    Nook.xcodeproj
    Nook/                   # App 目标（iPad only）
      NookApp.swift
      Models/{Folder,Item,Tag}.swift
      Services/{LibraryStore,TextExtractor,SearchService,LibraryLayout}.swift
      Views/{LibraryView,FolderSidebar,ItemGrid,SearchBar,TagFilterBar}.swift
      Preview/{PreviewContainer,PDFPreview,ImagePreview,HTMLPreview}.swift
      Output/{ShareService,PrintService}.swift
      Sync/{ICloudSync,SyncStatusView}.swift
      Support/{NameDeduper,PathSanitizer,ItemKind}.swift
      Nook.entitlements
    NookShare/              # 分享扩展目标
      ShareViewController.swift
      Info.plist
      NookShare.entitlements
  tests/                    # 测试源码（被 NookTests 目标引用）
    NookTests/
      NameDeduperTests.swift
      PathSanitizerTests.swift
      SearchFilterTests.swift
      LibraryLayoutTests.swift
      LibraryStoreTests.swift
      TextExtractorTests.swift
    README.md
```

> Xcode 工程位于 `src/Nook.xcodeproj`，测试目标 `NookTests` 引用 `../tests/NookTests`。
>
> 工程另含模板自带的 **`NookUITests`** 目标，以及模板占位文件 `src/Nook/ContentView.swift`、`src/Nook/Item.swift`；**Task 7 会用 `Models/` 下的自定义模型替换占位**（避免与自定义 `Item` 同名冲突）。

**构建与测试通道**（重要，每个任务复用）：
本机 agent shell 被沙箱化，直接执行 `xcodebuild` 会失败（`sandbox-exec: sandbox_apply: Operation not permitted`，Swift 宏插件无法启动）。因此统一改用 **Xcode 工具链（经 `run_mcp`）**：
- 构建：`BuildProject`
- 测试：`RunAllTests`
- 目标机：模拟器 `iPad Pro 13-inch (M4)`，**必须带 `OS=26.0`**（同名设备存在 18.4/18.5/26.0 三个）

> 下文任务中出现的 `xcodebuild …` 命令，等价映射为「`BuildProject` / `RunAllTests`」；若在普通终端或 Xcode GUI 中执行，等价命令为：
> `xcodebuild test -project src/Nook.xcodeproj -scheme Nook -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4),OS=26.0'`

---

## Phase 0 · 工程骨架

### Task 1: 创建 Xcode 工程与目标

**Files:**
- Create: `src/Nook.xcodeproj`
- Create: `src/Nook/NookApp.swift`
- Create: `tests/NookTests/SmokeTests.swift`

- [ ] **Step 1: 新建工程（用 Xcode 工具链，而非 GUI）**
  1) 调用 Xcode 工具 `XcodeListTemplates`（kind=`project`），取 iOS App 模板标识与可用选项（如 `languageChoice`、`coreData`、`sceneLifecycle`、`testingSystem`）。
  2) 调用 `XcodeNewProject` 创建：
     - `templateIdentifier`：上一步得到的 iOS App 模板标识
     - `productName`：`Nook`
     - `organizationIdentifier`：`com.nook`
     - `destinationPath`：`/Users/heminghui/develop/Nook/02-development/src`
     - `options`：Interface=**SwiftUI**、Storage=**SwiftData**、Testing=**Swift Testing**、仅 **iPad**（不选 iPhone）
  3) 预期生成 `src/Nook.xcodeproj` 与 `src/Nook/` 源目录。
- [ ] **Step 2: 设置最低版本与 Bundle ID**
  Target `Nook` → General：Minimum Deployments = **iPadOS 17.0**；Bundle Identifier = `com.nook.app`。
- [ ] **Step 3: 新增 Share Extension 目标**
  调用 Xcode 工具 `XcodeNewTarget` 新增 **Share Extension** 目标，名 `NookShare`，嵌入（Embed）到 `Nook`。
- [ ] **Step 4: 确认单元测试目标存在**
  应存在 `NookTests`；将测试文件目录指向 `tests/NookTests`（Target → Build Settings → 或直接将文件加入）。
- [ ] **Step 5: 写冒烟测试**

```swift
import Testing

@Suite struct SmokeTests {
    @Test func appTargetCompiles() {
        #expect(1 + 1 == 2)
    }
}
```

- [ ] **Step 6: 运行测试并确认通过**

Run: `xcodebuild test -project src/Nook.xcodeproj -scheme Nook -destination 'platform=iOS Simulator,name=<iPad 设备>'`
Expected: `** TEST SUCCEEDED **`

- [ ] **Step 7: 提交**

```bash
git add src/ tests/
git commit -m "chore: 初始化 Nook Xcode 工程与目标"
```

---

## Phase 1 · 核心纯逻辑（TDD，可快速验证）

### Task 2: NameDeduper（重名去重）

**Files:**
- Create: `src/Nook/Support/NameDeduper.swift`
- Test: `tests/NookTests/NameDeduperTests.swift`

- [ ] **Step 1: 写失败测试**

```swift
import Testing
@testable import Nook

@Suite struct NameDeduperTests {
    @Test func keepsNameWhenUnique() {
        #expect(NameDeduper.uniqueName("函数.pdf", existing: []) == "函数.pdf")
    }
    @Test func appendsCounterOnConflict() {
        let existing: Set<String> = ["函数.pdf"]
        #expect(NameDeduper.uniqueName("函数.pdf", existing: existing) == "函数 (1).pdf")
    }
    @Test func incrementsUntilFree() {
        let existing: Set<String> = ["函数.pdf", "函数 (1).pdf", "函数 (2).pdf"]
        #expect(NameDeduper.uniqueName("函数.pdf", existing: existing) == "函数 (3).pdf")
    }
    @Test func handlesNoExtension() {
        let existing: Set<String> = ["未命名"]
        #expect(NameDeduper.uniqueName("未命名", existing: existing) == "未命名 (1)")
    }
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: 同 Task 1 的测试命令
Expected: FAIL（`NameDeduper` 未定义）

- [ ] **Step 3: 实现**

```swift
import Foundation

enum NameDeduper {
    static func uniqueName(_ desired: String, existing: Set<String>) -> String {
        guard existing.contains(desired) else { return desired }
        let url = URL(fileURLWithPath: desired)
        let ext = url.pathExtension
        let base = url.deletingPathExtension().lastPathComponent
        var i = 1
        while true {
            let candidate = ext.isEmpty ? "\(base) (\(i))" : "\(base) (\(i)).\(ext)"
            if !existing.contains(candidate) { return candidate }
            i += 1
        }
    }
}
```

- [ ] **Step 4: 运行测试确认通过** → Expected: `** TEST SUCCEEDED **`

- [ ] **Step 5: 提交**

```bash
git add src/Nook/Support/NameDeduper.swift tests/NookTests/NameDeduperTests.swift
git commit -m "feat: 文件名去重 NameDeduper"
```

### Task 3: PathSanitizer（路径安全）

**Files:**
- Create: `src/Nook/Support/PathSanitizer.swift`
- Test: `tests/NookTests/PathSanitizerTests.swift`

- [ ] **Step 1: 写失败测试**

```swift
import Testing
@testable import Nook

@Suite struct PathSanitizerTests {
    @Test func replacesForbiddenCharacters() {
        #expect(PathSanitizer.sanitize("a/b:c?d") == "a_b_c_d")
    }
    @Test func fallsBackOnEmpty() {
        #expect(PathSanitizer.sanitize("   ") == "未命名")
    }
    @Test func detectsTraversal() {
        #expect(PathSanitizer.isSafe(relativePath: "数学/../秘密") == false)
        #expect(PathSanitizer.isSafe(relativePath: "数学/高一/函数.pdf") == true)
    }
}
```

- [ ] **Step 2: 运行测试确认失败** → Expected: FAIL

- [ ] **Step 3: 实现**

```swift
import Foundation

enum PathSanitizer {
    private static let forbidden = CharacterSet(charactersIn: "/\\:*?\"<>|")

    static func sanitize(_ name: String) -> String {
        let cleaned = name.components(separatedBy: forbidden).joined(separator: "_")
        let trimmed = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "未命名" : trimmed
    }

    static func isSafe(relativePath: String) -> Bool {
        !relativePath.split(separator: "/").contains("..")
    }
}
```

- [ ] **Step 4: 运行测试确认通过** → Expected: PASS
- [ ] **Step 5: 提交**

```bash
git add src/Nook/Support/PathSanitizer.swift tests/NookTests/PathSanitizerTests.swift
git commit -m "feat: 路径清洗与安全校验 PathSanitizer"
```

### Task 4: ItemKind（文件类型归类）

**Files:**
- Create: `src/Nook/Support/ItemKind.swift`

- [ ] **Step 1: 实现**

```swift
import Foundation
import UniformTypeIdentifiers

enum ItemKind: String, Codable, CaseIterable {
    case pdf, image, html, other

    static func from(extension ext: String) -> ItemKind {
        switch ext.lowercased() {
        case "pdf": return .pdf
        case "png", "jpg", "jpeg", "heic", "gif", "webp": return .image
        case "html", "htm": return .html
        default: return .other
        }
    }

    static func from(url: URL) -> ItemKind {
        let ext = url.pathExtension
        if let type = UTType(filenameExtension: ext) {
            if type.conforms(to: .pdf) { return .pdf }
            if type.conforms(to: .image) { return .image }
            if type.conforms(to: .html) { return .html }
        }
        return from(extension: ext)
    }
}
```

- [ ] **Step 2: 提交**

```bash
git add src/Nook/Support/ItemKind.swift
git commit -m "feat: 文件类型归类 ItemKind"
```

### Task 5: SearchFilter（检索过滤纯逻辑）

> 说明：SwiftData 的动态谓词对"标签集合 + 文件夹范围"支持有限，故把**过滤决策**下沉为纯函数、可完整单测；查询先用谓词粗筛文本，再用本函数精筛。

**Files:**
- Create: `src/Nook/Services/SearchService.swift`（本任务先只放 `SearchCriteria` 与 `matches`）
- Test: `tests/NookTests/SearchFilterTests.swift`

- [ ] **Step 1: 写失败测试**

```swift
import Testing
@testable import Nook

@Suite struct SearchFilterTests {
    private let item = SearchService.Snapshot(
        id: UUID(), folderID: UUID(), folderAncestors: [UUID()],
        fileName: "函数专项练习.pdf", textContent: "一次函数 与 二次函数",
        tagIDs: [UUID(), UUID()]
    )

    @Test func matchesTextInFileName() {
        var c = SearchService.Criteria(); c.text = "函数"
        #expect(SearchService.matches(item, c))
    }
    @Test func matchesTextInContent() {
        var c = SearchService.Criteria(); c.text = "二次"
        #expect(SearchService.matches(item, c))
    }
    @Test func rejectsWhenTextMissing() {
        var c = SearchService.Criteria(); c.text = "英语"
        #expect(!SearchService.matches(item, c))
    }
    @Test func folderScopeExcludesOutsiders() {
        var c = SearchService.Criteria(); c.folderScope = UUID()
        #expect(!SearchService.matches(item, c))
    }
    @Test func matchAllTagsRequiresEveryTag() {
        var c = SearchService.Criteria(); c.tagIDs = Set(item.tagIDs); c.matchAllTags = true
        #expect(SearchService.matches(item, c))
        c.tagIDs.insert(UUID())
        #expect(!SearchService.matches(item, c))
    }
    @Test func matchAnyTagRequiresOne() {
        var c = SearchService.Criteria(); c.tagIDs = [UUID()]; c.matchAllTags = false
        #expect(!SearchService.matches(item, c))
    }
}
```

- [ ] **Step 2: 运行测试确认失败** → Expected: FAIL

- [ ] **Step 3: 实现**

```swift
import Foundation

enum SearchService {
    struct Criteria {
        var text: String = ""
        var folderScope: UUID? = nil
        var tagIDs: Set<UUID> = []
        var matchAllTags: Bool = false
    }

    struct Snapshot {
        let id: UUID
        let folderID: UUID
        let folderAncestors: [UUID]
        let fileName: String
        let textContent: String
        let tagIDs: [UUID]
    }

    static func matches(_ s: Snapshot, _ c: Criteria) -> Bool {
        if !c.text.isEmpty {
            let q = c.text.lowercased()
            let hit = s.fileName.lowercased().contains(q) || s.textContent.lowercased().contains(q)
            if !hit { return false }
        }
        if let scope = c.folderScope, !s.folderAncestors.contains(scope) { return false }
        if !c.tagIDs.isEmpty {
            let set = Set(s.tagIDs)
            if c.matchAllTags {
                if !c.tagIDs.isSubset(of: set) { return false }
            } else {
                if c.tagIDs.isDisjoint(with: set) { return false }
            }
        }
        return true
    }
}
```

- [ ] **Step 4: 运行测试确认通过** → Expected: PASS
- [ ] **Step 5: 提交**

```bash
git add src/Nook/Services/SearchService.swift tests/NookTests/SearchFilterTests.swift
git commit -m "feat: 检索过滤纯逻辑 SearchFilter"
```

### Task 6: LibraryLayout（磁盘布局）

**Files:**
- Create: `src/Nook/Services/LibraryLayout.swift`
- Test: `tests/NookTests/LibraryLayoutTests.swift`

- [ ] **Step 1: 写失败测试**

```swift
import Testing
@testable import Nook

@Suite struct LibraryLayoutTests {
    @Test func buildsNestedRelativePath() {
        let p = LibraryLayout.relativePath(folderNames: ["数学", "高一", "函数"], fileName: "习题.pdf")
        #expect(p == "Library/数学/高一/函数/习题.pdf")
    }
    @Test func rootFilePath() {
        #expect(LibraryLayout.relativePath(folderNames: [], fileName: "a.html") == "Library/a.html")
    }
    @Test func metaDirIsHidden() {
        #expect(LibraryLayout.metaDirName == ".nook")
    }
}
```

- [ ] **Step 2: 运行测试确认失败** → Expected: FAIL

- [ ] **Step 3: 实现**

```swift
import Foundation

enum LibraryLayout {
    static let rootFolderName = "Library"
    static let metaDirName = ".nook"

    static func relativePath(folderNames: [String], fileName: String) -> String {
        ([rootFolderName] + folderNames + [fileName]).joined(separator: "/")
    }
}
```

- [ ] **Step 4: 运行测试确认通过** → Expected: PASS
- [ ] **Step 5: 提交**

```bash
git add src/Nook/Services/LibraryLayout.swift tests/NookTests/LibraryLayoutTests.swift
git commit -m "feat: 资料库磁盘布局 LibraryLayout"
```

---

## Phase 2 · 数据层（SwiftData）

### Task 7: 数据模型

**Files:**
- Create: `src/Nook/Models/Folder.swift`、`Item.swift`、`Tag.swift`

- [ ] **Step 0: 清理模板占位**
  删除模板自带的 `src/Nook/Item.swift`（与自定义模型同名冲突）与 `src/Nook/ContentView.swift`（改由 `Views/` 承载）；保留 `NookApp.swift`。
- [ ] **Step 1: 实现模型**

```swift
import Foundation
import SwiftData

@Model final class Folder {
    @Attribute(.unique) var id: UUID
    var name: String
    var sortOrder: Int
    var createdAt: Date
    var parent: Folder?
    @Relationship(deleteRule: .cascade, inverse: \Folder.children) var children: [Folder] = []
    @Relationship(deleteRule: .cascade, inverse: \Item.folder) var items: [Item] = []

    init(id: UUID = UUID(), name: String, sortOrder: Int = 0, parent: Folder? = nil) {
        self.id = id; self.name = name; self.sortOrder = sortOrder
        self.createdAt = Date(); self.parent = parent
    }
}

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
    var folder: Folder?
    @Relationship(inverse: \Tag.items) var tags: [Tag] = []

    init(id: UUID = UUID(), fileName: String, relativePath: String, kind: ItemKind, size: Int) {
        self.id = id; self.fileName = fileName; self.relativePath = relativePath
        self.kindRaw = kind.rawValue; self.size = size
        self.importedAt = Date(); self.modifiedAt = Date()
        self.textContent = ""; self.indexState = "pending"
    }

    var kind: ItemKind { ItemKind(rawValue: kindRaw) ?? .other }
}

@Model final class Tag {
    @Attribute(.unique) var id: UUID
    var name: String
    var colorHex: String
    var items: [Item] = []

    init(id: UUID = UUID(), name: String, colorHex: String = "#3B6CF6") {
        self.id = id; self.name = name; self.colorHex = colorHex
    }
}
```

- [ ] **Step 2: 注册容器**（`NookApp.swift`）

```swift
import SwiftUI
import SwiftData

@main
struct NookApp: App {
    var body: some Scene {
        WindowGroup { LibraryView() }
            .modelContainer(for: [Folder.self, Item.self, Tag.self])
    }
}
```

- [ ] **Step 3: 构建确认通过**

Run: `xcodebuild build -project src/Nook.xcodeproj -scheme Nook -destination 'platform=iOS Simulator,name=<iPad 设备>'`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 4: 提交**

```bash
git add src/Nook/Models/ src/Nook/NookApp.swift
git commit -m "feat: SwiftData 数据模型 Folder/Item/Tag"
```

### Task 8: LibraryStore（CRUD + 磁盘 I/O + 索引登记）

**Files:**
- Create: `src/Nook/Services/LibraryStore.swift`
- Test: `tests/NookTests/LibraryStoreTests.swift`

- [ ] **Step 1: 写失败测试**（用内存容器）

```swift
import Testing
import SwiftData
import Foundation
@testable import Nook

@MainActor
@Suite struct LibraryStoreTests {
    private func makeStore() throws -> LibraryStore {
        let cfg = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Folder.self, Item.self, Tag.self, configurations: cfg)
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        return LibraryStore(context: container.mainContext, rootURL: root)
    }

    @Test func createsNestedFolders() throws {
        let store = try makeStore()
        let a = try store.createFolder(named: "数学", parent: nil)
        let b = try store.createFolder(named: "高一", parent: a)
        #expect(b.parent?.id == a.id)
    }

    @Test func importFileWritesToDiskAndRegisters() throws {
        let store = try makeStore()
        let src = FileManager.default.temporaryDirectory.appendingPathComponent("习题.pdf")
        try Data("hello".utf8).write(to: src)
        let folder = try store.createFolder(named: "数学", parent: nil)
        let item = try store.importFile(at: src, into: folder)
        #expect(item.fileName == "习题.pdf")
        #expect(FileManager.default.fileExists(atPath: store.absoluteURL(for: item).path))
    }

    @Test func deduplicatesOnImport() throws {
        let store = try makeStore()
        let folder = try store.createFolder(named: "数学", parent: nil)
        let src = FileManager.default.temporaryDirectory.appendingPathComponent("习题.pdf")
        try Data("x".utf8).write(to: src)
        _ = try store.importFile(at: src, into: folder)
        let second = try store.importFile(at: src, into: folder)
        #expect(second.fileName == "习题 (1).pdf")
    }

    @Test func taggingAndFetch() throws {
        let store = try makeStore()
        let folder = try store.createFolder(named: "数学", parent: nil)
        let src = FileManager.default.temporaryDirectory.appendingPathComponent("a.pdf")
        try Data("x".utf8).write(to: src)
        let item = try store.importFile(at: src, into: folder)
        let tag = try store.createTag(named: "易错")
        try store.addTag(tag, to: item)
        #expect(item.tags.contains { $0.id == tag.id })
    }
}
```

- [ ] **Step 2: 运行测试确认失败** → Expected: FAIL

- [ ] **Step 3: 实现**（要点）

```swift
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
    }

    func ancestors(of folder: Folder?) -> [UUID] {
        var result: [UUID] = []
        var current = folder
        while let f = current { result.append(f.id); current = f.parent }
        return result
    }

    func createFolder(named raw: String, parent: Folder?) throws -> Folder {
        let name = PathSanitizer.sanitize(raw)
        let folder = Folder(name: name, parent: parent)
        context.insert(folder)
        try fm.createDirectory(at: folderURL(for: folder), withIntermediateDirectories: true)
        try context.save()
        return folder
    }

    func folderURL(for folder: Folder) -> URL {
        let names = ancestors(of: folder).reversed().compactMap { id in
            (try? context.fetch(FetchDescriptor<Folder>(predicate: #Predicate { $0.id == id })))?.first?.name
        }
        return names.reduce(rootURL) { $0.appendingPathComponent($1) }
    }

    func importFile(at source: URL, into folder: Folder?) throws -> Item {
        let destDir = try folder.map { try ensureDir(folderURL(for: $0)) } ?? ensureDir(rootURL)
        let existing = Set((try? fm.contentsOfDirectory(atPath: destDir.path)) ?? [])
        let fileName = NameDeduper.uniqueName(source.lastPathComponent, existing: existing)
        let dest = destDir.appendingPathComponent(fileName)
        if fm.fileExists(atPath: dest.path) { try fm.removeItem(at: dest) }
        try fm.copyItem(at: source, to: dest)
        let attrs = try fm.attributesOfItem(atPath: dest.path)
        let size = (attrs[.size] as? Int) ?? 0
        let item = Item(fileName: fileName, relativePath: relativePath(of: dest),
                        kind: ItemKind.from(url: dest), size: size)
        item.folder = folder
        context.insert(item)
        try context.save()
        return item
    }

    func createTag(named raw: String, colorHex: String = "#3B6CF6") throws -> Tag {
        let tag = Tag(name: PathSanitizer.sanitize(raw), colorHex: colorHex)
        context.insert(tag); try context.save(); return tag
    }

    func addTag(_ tag: Tag, to item: Item) throws {
        if !item.tags.contains(where: { $0.id == tag.id }) { item.tags.append(tag) }
        try context.save()
    }

    func absoluteURL(for item: Item) -> URL { rootURL.appendingPathComponent(item.relativePath) }

    func relativePath(of url: URL) -> String {
        url.path.replacingOccurrences(of: rootURL.path + "/", with: "")
    }

    private func ensureDir(_ url: URL) throws -> URL {
        try fm.createDirectory(at: url, withIntermediateDirectories: true); return url
    }
}
```

> 注：`folderURL(for:)` 用同步 fetch 递归取父级名，若层级深可改为在 `Folder` 上缓存 `pathComponents`，但在 ≤5 层下无性能问题，先保持简单（YAGNI）。

- [ ] **Step 4: 运行测试确认通过** → Expected: PASS（4 个用例）
- [ ] **Step 5: 提交**

```bash
git add src/Nook/Services/LibraryStore.swift tests/NookTests/LibraryStoreTests.swift
git commit -m "feat: 数据层 LibraryStore（CRUD + 落盘 + 去重）"
```

---

## Phase 3 · 文本抽取与检索接线

### Task 9: TextExtractor（PDF/HTML 正文抽取）

**Files:**
- Create: `src/Nook/Services/TextExtractor.swift`
- Test: `tests/NookTests/TextExtractorTests.swift`

- [ ] **Step 1: 写失败测试**（HTML 用字符串即可测）

```swift
import Testing
@testable import Nook

@Suite struct TextExtractorTests {
    @Test func stripsHTMLTags() {
        let html = "<html><body><h1>函数</h1><p>二次函数</p></body></html>"
        let text = TextExtractor.plainText(fromHTML: html)
        #expect(text.contains("函数"))
        #expect(!text.contains("<"))
    }
}
```

- [ ] **Step 2: 运行测试确认失败** → Expected: FAIL

- [ ] **Step 3: 实现**

```swift
import Foundation
import PDFKit

enum TextExtractor {
    static func plainText(fromHTML html: String) -> String {
        var out = ""
        var inTag = false
        for ch in html {
            if ch == "<" { inTag = true; continue }
            if ch == ">" { inTag = false; out.append(" "); continue }
            if !inTag { out.append(ch) }
        }
        return out.split(whereSeparator: { $0 == " " || $0.isNewline })
                  .joined(separator: " ")
    }

    static func extract(from url: URL, kind: ItemKind) -> String {
        switch kind {
        case .pdf:
            guard let doc = PDFDocument(url: url) else { return "" }
            return (0..<doc.pageCount).compactMap { doc.page(at: $0)?.string }.joined(separator: "\n")
        case .html:
            let html = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
            return plainText(fromHTML: html)
        default:
            return ""
        }
    }
}
```

- [ ] **Step 4: 运行测试确认通过** → Expected: PASS
- [ ] **Step 5: 提交**

```bash
git add src/Nook/Services/TextExtractor.swift tests/NookTests/TextExtractorTests.swift
git commit -m "feat: 文本抽取 TextExtractor（PDF/HTML）"
```

### Task 10: 检索接线（把抽取文本写入 Item 并按条件查询）

**Files:**
- Modify: `src/Nook/Services/LibraryStore.swift`
- Create: `src/Nook/Services/IndexingPipeline.swift`

- [ ] **Step 1: 实现索引管道**

```swift
import Foundation
import SwiftData

@MainActor
enum IndexingPipeline {
    static func index(item: Item, store: LibraryStore) {
        let url = store.absoluteURL(for: item)
        item.textContent = TextExtractor.extract(from: url, kind: item.kind)
        item.indexState = "indexed"
        try? store.context.save()
    }
}
```

- [ ] **Step 2: 在导入后触发索引**
  在 `LibraryStore.importFile` 返回前调用 `IndexingPipeline.index(item: item, store: self)`（可放 DispatchQueue 后台，v1 先同步）。
- [ ] **Step 3: 实现检索查询**（加到 `SearchService`）

```swift
extension SearchService {
    @MainActor
    static func search(_ criteria: Criteria, store: LibraryStore) -> [Item] {
        let all = (try? store.context.fetch(FetchDescriptor<Item>())) ?? []
        return all
            .map { item in
                Snapshot(id: item.id, folderID: item.folder?.id ?? UUID(),
                         folderAncestors: store.ancestors(of: item.folder),
                         fileName: item.fileName, textContent: item.textContent,
                         tagIDs: item.tags.map(\.id))
            }
            .enumerated()
            .filter { matches($0.element, criteria) }
            .map { all[$0.offset] }
    }
}
```

- [ ] **Step 4: 构建确认通过** → Expected: BUILD SUCCEEDED
- [ ] **Step 5: 提交**

```bash
git add src/Nook/Services/
git commit -m "feat: 索引管道与检索接线"
```

---

## Phase 4 · 预览

### Task 11: 预览容器（PDF / 图片 / HTML / 其他）

**Files:**
- Create: `src/Nook/Preview/PreviewContainer.swift`、`PDFPreview.swift`、`ImagePreview.swift`、`HTMLPreview.swift`

- [ ] **Step 1: 实现 HTML 预览（WKWebView）**

```swift
import SwiftUI
import WebKit

struct HTMLPreview: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView {
        let web = WKWebView()
        web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        return web
    }
    func updateUIView(_ web: WKWebView, context: Context) {}
}
```

- [ ] **Step 2: 实现 PDF 预览（PDFKit）**

```swift
import SwiftUI
import PDFKit

struct PDFPreview: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> PDFView {
        let view = PDFView(); view.autoScales = true
        view.document = PDFDocument(url: url); return view
    }
    func updateUIView(_ view: PDFView, context: Context) {}
}
```

- [ ] **Step 3: 图片预览**

```swift
import SwiftUI

struct ImagePreview: View {
    let url: URL
    var body: some View {
        if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
            Image(uiImage: image).resizable().scaledToFit()
        } else {
            ContentUnavailableView("无法显示图片", systemImage: "photo")
        }
    }
}
```

- [ ] **Step 4: 容器分发**

```swift
import SwiftUI

struct PreviewContainer: View {
    let item: Item
    let url: URL
    var body: some View {
        Group {
            switch item.kind {
            case .pdf: PDFPreview(url: url)
            case .image: ImagePreview(url: url)
            case .html: HTMLPreview(url: url)
            case .other: QuickLookPreview(url: url)
            }
        }
        .navigationTitle(item.fileName)
        .overlay(alignment: .bottom) {
            if item.kind == .html {
                Text("HTML 若引用外部资源，部分内容可能无法显示")
                    .font(.footnote).padding(6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.bottom, 8)
            }
        }
    }
}
```

- [ ] **Step 5: 实现 `QuickLookPreview`（QLPreviewController 包装）**

```swift
import SwiftUI
import QuickLook

struct QuickLookPreview: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> QLPreviewController {
        let c = QLPreviewController()
        c.dataSource = context.coordinator
        return c
    }
    func updateUIViewController(_ c: QLPreviewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(url: url) }

    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL
        init(url: URL) { self.url = url }
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as NSURL
        }
    }
}
```

- [ ] **Step 6: 构建确认通过** → Expected: BUILD SUCCEEDED
- [ ] **Step 7: 提交**

```bash
git add src/Nook/Preview/
git commit -m "feat: PDF/图片/HTML/通用 预览"
```

---

## Phase 5 · 分享与打印

### Task 12: 分享与打印

**Files:**
- Create: `src/Nook/Output/ShareService.swift`、`PrintService.swift`

- [ ] **Step 1: 实现分享（系统分享面板）**

```swift
import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ c: UIActivityViewController, context: Context) {}
}
```

- [ ] **Step 2: 实现打印**

```swift
import UIKit

enum PrintService {
    @MainActor
    static func printPDF(url: URL) {
        guard let doc = UIPrintInteractionController.shared.printFormatter,
              let controller = UIPrintInteractionController.shared as UIPrintInteractionController? else { return }
        _ = doc
        controller.printingItem = url
        controller.present(animated: true)
    }
}
```

> 说明：分享面板会列出微信/QQ/AirDrop/存储到文件，**无需任何申请**（见 product-spec FR-7）。

- [ ] **Step 3: 构建确认通过** → Expected: BUILD SUCCEEDED
- [ ] **Step 4: 提交**

```bash
git add src/Nook/Output/
git commit -m "feat: 系统分享与打印"
```

---

## Phase 6 · 分享扩展（收资料）

### Task 13: Share Extension

**Files:**
- Modify/Create: `src/NookShare/ShareViewController.swift`、`src/NookShare/Info.plist`

- [ ] **Step 1: 配置 App Group**
  在 `Nook` 与 `NookShare` 两个 target 的 Signing & Capabilities 中启用 **App Groups**，加入 `group.com.nook.app`。
- [ ] **Step 2: 接收分享内容并写入共享容器**

```swift
import UIKit
import UniformTypeIdentifiers

@MainActor
final class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = "存入 Nook"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        handleInputs()
    }

    private func handleInputs() {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else { return }
        for item in items {
            for provider in item.attachments ?? [] {
                if provider.hasItemConformingToTypeIdentifier(UTType.pdf.identifier) {
                    provider.loadFileRepresentation(forTypeIdentifier: UTType.pdf.identifier) { url, _ in
                        guard let url else { return }
                        ShareInbox.copy(url: url)
                    }
                }
            }
        }
    }
}

enum ShareInbox {
    static var inboxURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.nook.app")?
            .appendingPathComponent("Inbox", isDirectory: true)
    }
    static func copy(url: URL) {
        guard let dir = inboxURL else { return }
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let dest = dir.appendingPathComponent(url.lastPathComponent)
        try? FileManager.default.removeItem(at: dest)
        try? FileManager.default.copyItem(at: url, to: dest)
    }
}
```

- [ ] **Step 3: 主 App 启动时导入 Inbox**
  在 `LibraryView.task {}` 中扫描 `Inbox` 并导入到"未分类"文件夹，然后清空 Inbox（重复文件走 `NameDeduper`）。
- [ ] **Step 4: 构建确认通过** → Expected: BUILD SUCCEEDED
- [ ] **Step 5: 提交**

```bash
git add src/NookShare/ src/Nook/
git commit -m "feat: 分享扩展收资料（App Group 收件箱）"
```

---

## Phase 7 · iCloud

### Task 14: iCloud 备份/同步

**Files:**
- Create: `src/Nook/Sync/ICloudSync.swift`、`src/Nook/Sync/SyncStatusView.swift`
- Modify: `src/Nook/Nook.entitlements`

- [ ] **Step 1: 启用 iCloud Documents**
  Target `Nook` → Signing & Capabilities → **iCloud** → 勾选 **iCloud Documents**，Container 使用 `iCloud.com.nook.app`。
- [ ] **Step 2: 把资料库根目录指向 iCloud 容器**

```swift
import Foundation

enum ICloudSync {
    static func libraryRoot() -> URL {
        if let container = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.nook.app") {
            return container.appendingPathComponent("Documents/Library", isDirectory: true)
        }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Library", isDirectory: true)
    }
}
```

- [ ] **Step 3: 状态视图**（简单版）

```swift
import SwiftUI

struct SyncStatusView: View {
    let enabled: Bool
    var body: some View {
        Label(enabled ? "iCloud 同步已开启" : "仅本机（未登录 iCloud）",
              systemImage: enabled ? "icloud.fill" : "icloud.slash")
            .font(.footnote).foregroundStyle(.secondary)
    }
}
```

- [ ] **Step 4: 构建确认通过** → Expected: BUILD SUCCEEDED
- [ ] **Step 5: 提交**

```bash
git add src/Nook/Sync/ src/Nook/Nook.entitlements
git commit -m "feat: iCloud 备份/同步接入"
```

---

## Phase 8 · UI 集成

### Task 15: 主界面（文件夹树 + 资料列表 + 标签筛选 + 搜索）

**Files:**
- Create: `src/Nook/Views/LibraryView.swift`、`FolderSidebar.swift`、`ItemGrid.swift`、`SearchBar.swift`、`TagFilterBar.swift`

- [ ] **Step 1: 三栏骨架**

```swift
import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var context
    @State private var criteria = SearchService.Criteria()
    @State private var selection: Folder?
    @State private var store: LibraryStore?

    var body: some View {
        NavigationSplitView {
            FolderSidebar(selection: $selection)
        } detail: {
            VStack(spacing: 0) {
                SearchBar(criteria: $criteria)
                TagFilterBar(criteria: $criteria)
                ItemGrid(criteria: criteria, folderScope: selection)
            }
        }
        .task {
            if store == nil {
                store = LibraryStore(context: context, rootURL: ICloudSync.libraryRoot())
            }
        }
    }
}
```

- [ ] **Step 2: 资料列表（网格）**

```swift
import SwiftUI
import SwiftData

struct ItemGrid: View {
    @Environment(\.modelContext) private var context
    let criteria: SearchService.Criteria
    let folderScope: Folder?

    var body: some View {
        EmptyView()
    }
}
```

> 实现按 `SearchService.search` 取结果渲染 `LazyVGrid`；每项展示缩略图 + 文件名；点开进入 `PreviewContainer`。

- [ ] **Step 3: 文件夹树、搜索栏、标签栏**
  分别实现：可展开的 `Folder` 树（`List` + `OutlineGroup`）、绑定 `criteria.text` 的搜索框、多选标签并切换 `matchAllTags` 的横排条。
- [ ] **Step 4: 构建确认通过** → Expected: BUILD SUCCEEDED
- [ ] **Step 5: 提交**

```bash
git add src/Nook/Views/
git commit -m "feat: 主界面（文件夹树/列表/标签/搜索）"
```

### Task 16: 导入流程（含多选与批量打标签）

**Files:**
- Modify: `src/Nook/Views/LibraryView.swift`
- Create: `src/Nook/Views/ImportFlowView.swift`

- [ ] **Step 1: 用系统文件选择器导入**

```swift
import SwiftUI
import UniformTypeIdentifiers

struct ImportFlowView: View {
    let store: LibraryStore
    let target: Folder?
    @State private var showing = false

    var body: some View {
        Button("导入", systemImage: "square.and.arrow.down") { showing = true }
            .fileImporter(isPresented: $showing, allowedContentTypes: [.item],
                          allowsMultipleSelection: true) { result in
                guard case .success(let urls) = result else { return }
                for url in urls {
                    let access = url.startAccessingSecurityScopedResource()
                    defer { if access { url.stopAccessingSecurityScopedResource() } }
                    _ = try? store.importFile(at: url, into: target)
                }
            }
    }
}
```

- [ ] **Step 2: 批量打标签**：导入完成后弹出标签多选面板，对新建 Item 批量 `addTag`。
- [ ] **Step 3: 构建确认通过** → Expected: BUILD SUCCEEDED
- [ ] **Step 4: 提交**

```bash
git add src/Nook/Views/
git commit -m "feat: 资料导入流程（多选 + 批量标签）"
```

---

## Phase 9 · 测试补齐与收尾

### Task 17: 补齐集成/UI 测试并全量运行

**Files:**
- Create/Modify: `tests/NookTests/*`

- [ ] **Step 1: 集成测试：导入 → 索引 → 检索**

```swift
import Testing
import SwiftData
import Foundation
@testable import Nook

@MainActor
@Suite struct IntegrationTests {
    @Test func importThenSearchFindsByContent() throws {
        let cfg = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Folder.self, Item.self, Tag.self, configurations: cfg)
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let store = LibraryStore(context: container.mainContext, rootURL: root)

        let src = root.appendingPathComponent("函数练习.html")
        try "<html><body>二次函数 与 图像</body></html>".write(to: src, encoding: .utf8)

        let folder = try store.createFolder(named: "数学", parent: nil)
        let item = try store.importFile(at: src, into: folder)
        IndexingPipeline.index(item: item, store: store)

        var c = SearchService.Criteria(); c.text = "二次函数"
        let results = SearchService.search(c, store: store)
        #expect(results.contains { $0.id == item.id })
    }
}
```

- [ ] **Step 2: 运行全量测试**

Run: `xcodebuild test -project src/Nook.xcodeproj -scheme Nook -destination 'platform=iOS Simulator,name=<iPad 设备>'`
Expected: `** TEST SUCCEEDED **`（列出全部用例通过数）

- [ ] **Step 3: 记录结果**（通过数、耗时）到 `02-development/changelog.md`（Task 18）。
- [ ] **Step 4: 提交**

```bash
git add tests/
git commit -m "test: 集成测试（导入→索引→检索）+ 全量测试通过"
```

### Task 18: 更新开发日志

**Files:**
- Create: `02-development/changelog.md`

- [ ] **Step 1: 记录本次开发**

```markdown
# 开发日志（Changelog）

## 2026-09-27 · v1 首个可运行版本
- 完成：工程骨架、数据层（Folder/Item/Tag）、落盘与去重、文本抽取与检索、PDF/图片/HTML/通用预览、系统分享与打印、分享扩展收资料、iCloud 接入、主界面与导入流程。
- 测试：`xcodebuild test` 全量通过（<填写真实通过数/耗时>）。
- 已知限制：HTML 外链资源可能不显示；扫描件无 OCR；同步冲突为后写覆盖。
```

- [ ] **Step 2: 提交**

```bash
git add 02-development/changelog.md
git commit -m "docs: 更新开发日志 changelog"
```

---

## 自审（对照 design）

| product-spec 需求 | 对应任务 |
|-------------------|----------|
| FR-1 资料导入 | Task 8、16 |
| FR-2 文件夹（多级） | Task 7、8、15 |
| FR-3 资料管理 | Task 8、15 |
| FR-4 标签体系 | Task 7、8、15 |
| FR-5 检索（名/全文/标签+范围） | Task 5、9、10、17 |
| FR-6 预览（PDF/图片/HTML） | Task 11 |
| FR-7 分享与打印 | Task 12 |
| FR-8 分享扩展 | Task 13 |
| FR-9 iCloud | Task 14 |
| 验收标准全部 | Task 17 全量测试 + 真机安装 |

**占位符扫描**：无 TODO/TBD；`ItemGrid` 的渲染逻辑在 Task 15 内文说明（属 UI 组装，非算法）。
**类型一致性**：`ItemKind`、`SearchService.Criteria/Snapshot`、`LibraryStore.context/ancestors/absoluteURL` 在后续任务中保持一致。

---

## 执行方式

两种方式任选（见执行交接）：

1. **子代理逐任务（推荐）**：每个任务派一个全新子代理，任务间做两阶段评审，迭代快。
2. **会话内批量执行**：用 `executing-plans` 在本会话按批执行，带检查点评审。

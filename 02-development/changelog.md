# 开发日志（Changelog）

## 2026-10-18 · 资料标签编辑与移动

- 新增：资料长按/右键菜单「编辑标签」「移动到…」，预览页「更多」菜单同步提供
- 标签面板支持为单份资料勾选增删标签，并可内联新建标签
- 移动面板支持根目录与多级文件夹，移动时同步调整磁盘文件并自动处理重名
- 测试：真机全量 **28 项全部通过，0 失败**

## 2026-10-18 · v1 可运行版本

- 完成模块：
  - 纯逻辑：`NameDeduper`、`PathSanitizer`、`ItemKind`、`SearchService`（过滤 + 查询）、`LibraryLayout`
  - 数据层：`Folder` / `Item` / `Tag` SwiftData 模型，`LibraryStore`（文件夹/资料 CRUD、真实目录落盘、重名去重、标签关联）
  - 检索：`TextExtractor`（PDFKit 抽文本、HTML 去标签）、`IndexingPipeline`、导入后自动建索引
  - 预览：PDF（PDFKit）、图片、单文件 HTML（WKWebView）、其他（QuickLook）
  - 输出：系统分享面板、系统打印
  - 收资料：Share Extension + App Group 收件箱，主 App 启动时导入「未分类」
  - 同步：iCloud Documents 作为资料库根目录，未登录时回退本地 Documents
  - 界面：文件夹树、全部资料、搜索、标签筛选（任一/同时满足）、网格列表、导入（多选 + 批量打标签）、新建文件夹/标签
- 工程调整：
  - 新增共享 scheme `Nook.xcscheme`
  - `Nook` / `NookShare` 启用 App Group 与 iCloud Documents entitlement
- 测试：真机 `2025 iPad`（iPadOS 26.5）运行全量测试，**27 项全部通过，0 失败**（含 2 项 UI 测试）
- 运行验证：真机 `RunProject` 启动成功，无 error/fault 日志
- 已知限制：
  - HTML 引用外部资源时可能无法显示
  - 扫描件无 OCR
  - 文件夹的移动/重命名/删除与资料的复制/重命名暂未接入界面
  - 同步冲突为后写覆盖；未登录 iCloud 时仅本机可用

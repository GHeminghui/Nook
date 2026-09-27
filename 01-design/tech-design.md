# Nook 技术方案（Tech Design）

- 阶段：设计（design）
- 版本：v1
- 日期：2026-09-27
- 关联：[product-spec.md](./product-spec.md)、[architecture.html](./architecture.html)、[../00-discovery/research.md](../00-discovery/research.md)

---

## 1. 概述

Nook 是一个**原生 iPadOS 应用**（SwiftUI），采用「**真实文件夹 + 标签元数据**」双层组织模型：文件按真实目录存放在 App 沙盒 / iCloud 容器中，标签与索引存于本地数据库。

设计目标：本地优先、完全离线可用、面向非技术用户、可在 iPad 上完成"收 → 整 → 找 → 看 → 发"闭环。

## 2. 技术选型与理由

| 能力 | 选型 | 理由 |
|------|------|------|
| 语言 / UI | **Swift + SwiftUI** | 原生 iPadOS、开发环境已有 Xcode；SwiftUI 开发效率高 |
| 本地数据库 | **SwiftData**（iPadOS 17+） | 与 SwiftUI 集成好，声明式模型，满足 Folder/Item/Tag 关系建模 |
| PDF 渲染 / 取文本 | **PDFKit** | 系统框架，既能渲染又能抽取文本用于全文索引 |
| HTML 渲染 | **WKWebView** | 原生 WebView，可离线渲染单文件 HTML |
| 图片 | **PhotosUI / ImageIO** | 系统能力，支持缩放与多图浏览 |
| 通用预览 | **QuickLook** | 覆盖"其他"格式 |
| 系统分享 | **UIActivityViewController** | 微信/QQ/AirDrop 通过系统分享面板，**无需申请** |
| 打印 | **UIPrintInteractionController** | 系统打印 |
| 收资料入口 | **Share Extension** | 在任意 App 内"存入 Nook" |
| 全文索引 | **SQLite FTS5** | 轻量、离线、可控；比 CoreSpotlight 更易与自定义检索组合 |
| 同步 / 备份 | **iCloud Documents（ubiquity container）** | 文件 + 元数据一并同步，符合"本地为主 + 云备份" |
| 最低版本 | **iPadOS 17** | SwiftData 起步版本 |

## 3. 架构总览

分层（自下而上）：

```
┌──────────────────────────────────────────────┐
│                   UI 层 (SwiftUI)             │
│   资料库浏览 · 文件夹树 · 标签 · 搜索 · 预览   │
├──────────────────────────────────────────────┤
│                  领域服务层                    │
│  LibraryStore │ Indexer │ Preview │ Output    │
├──────────────────────────────────────────────┤
│                  数据/持久层                   │
│  SwiftData(元数据) │ 文件系统(真实目录) │ FTS5 │
├──────────────────────────────────────────────┤
│                  系统能力层                    │
│  PDFKit · WKWebView · QuickLook · Share · Print│
│  iCloud Documents · Share Extension           │
└──────────────────────────────────────────────┘
```

## 4. 数据模型

| 实体 | 字段 | 说明 |
|------|------|------|
| **Folder** | `id`、`name`、`parentId`、`sortOrder`、`createdAt` | 自引用实现**多级**；磁盘上对应真实目录 |
| **Item** | `id`、`folderId`、`fileName`、`storedPath`、`type`、`size`、`importedAt`、`modifiedAt`、`indexState` | 一份资料归属一个文件夹 |
| **Tag** | `id`、`name`、`color` | 全局标签 |
| **ItemTag** | `itemId`、`tagId` | 多对多关联 |

关系：`Folder 1─* Folder`（子文件夹）、`Folder 1─* Item`、`Item *─* Tag`（经 ItemTag）。

`indexState` ∈ {pending, indexed, failed}，用于全文索引状态跟踪。

## 5. 存储设计

### 5.1 磁盘布局

```
<App 容器>/
  Documents/
    Library/                 # 资料实体，镜像文件夹层级
      <Folder A>/
        <Folder A-1>/
          file.pdf
      file.html
    .nook/
      nook.store              # 元数据（SwiftData）
      index.fts5              # 全文索引（SQLite FTS5）
```

- 文件夹变更 = 目录变更 + 元数据变更，二者在同一事务语义下保持一致。
- 文件名去重：冲突时追加 `(1)`、`(2)`…

### 5.2 文本抽取
- PDF：`PDFDocument.string` 逐页抽取。
- HTML：剥离标签后取正文。
- 抽取结果写入 `index.fts5`。

## 6. 检索设计

检索条件可组合：

- **文本**：文件名 + 全文（FTS5 前缀/分词匹配）。
- **范围**：全部 / 当前文件夹（含子文件夹）。
- **标签**：多标签，模式为 `any`（满足任一）或 `all`（同时满足）。

执行：先由 FTS5 得到候选 Item 集合，再按文件夹范围与标签集合做交集过滤，最后排序返回。结果页对命中关键词高亮。

## 7. 同步设计（iCloud）

- 资料库目录放入 App 的 **iCloud Documents 容器**；文件与 `.nook/` 元数据一并同步。
- 单机离线时照常读写本地；联网后由系统负责同步。
- 冲突：先用"后写覆盖 + 用户提示"，版本历史/回收站留后续版本。

## 8. 分享扩展设计

- `ShareExtension` 目标与主 App 共享同一 App Group 容器 / 资料库路径。
- 接收类型：文件、图片、URL、文本。
- 流程：扩展内选目标文件夹 + 标签 → 写入资料库 → 标记待索引 → 交由主 App 或后台任务建索引。

## 9. 模块划分与职责

| 模块 | 职责 | 依赖 |
|------|------|------|
| `LibraryStore` | Folder/Item/Tag 的 CRUD、磁盘 I/O、命名去重、事务 | SwiftData、FileManager |
| `Indexer` | 文本抽取、FTS5 索引维护、检索查询 | PDFKit、SQLite |
| `Preview` | PDF/图片/HTML/其他 渲染 | PDFKit、WKWebView、QuickLook |
| `Output` | 分享面板、打印 | UIActivityViewController、UIPrintInteractionController |
| `Sync` | iCloud 容器接入与状态 | iCloud Documents |
| `ShareExtension` | 外部收资料入口 | 共享容器 |

每个模块单一职责、通过明确接口交互，可独立测试。

## 10. 安全与隐私

- 数据默认**本地**；iCloud 同步走用户自有 Apple ID 的私有容器。
- 不采集、不上报任何用户数据；无第三方分析 SDK。
- 沙盒内文件访问受系统权限约束。

## 11. 边界与错误处理

| 场景 | 处理 |
|------|------|
| 大文件导入 | 进度 + 可取消 + 失败回滚 |
| 重名 | 追加序号 |
| 删除文件夹 | 二次确认 + 级联 |
| 不支持格式 | 存为"其他"，通用预览 |
| HTML 外链资源 | 提示可能无法显示 |
| 同步冲突 | 后写覆盖 + 提示 |
| 存储不足 | 导入前检查 + 提示 |
| 索引失败 | `indexState=failed`，可重试，不影响查看 |

## 12. 测试策略

- **单元**：LibraryStore CRUD、多级文件夹、标签多对多、命名去重、FTS5 查询、范围/标签组合过滤。
- **集成**：导入 → 抽文本 → 建索引 → 检索 → 预览 全链路。
- **UI**：导入、打标签、检索、分享、打印 关键路径。
- **真机**：iPad 实机安装运行验证。
- 测试必须**真实运行**取得结果后方可判定通过（见 `AGENTS.md` 规则 7）。

## 13. 风险与后续

| 风险 | 应对 |
|------|------|
| 免费 Apple ID 签名 7 天到期 | 开发/上线阶段评估付费开发者账号 |
| iOS 沙盒/同步边界行为差异 | 真机验证；同步冲突策略逐步完善 |
| 全文索引对扫描件无效 | 后续版本引入 OCR |
| 单机实现的复杂度 | 模块化 + 单元测试保障 |

**后续版本**：手写批注、Mac 端、OCR、AI 辅助命名/摘要、微信深度分享、版本历史。

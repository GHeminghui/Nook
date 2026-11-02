# 发布说明 · v1.0.0（知栈 / KnowStack）

## 发布信息

| 项目 | 值 |
|---|---|
| App Store 版本 | `1.0` |
| 构建号 | `1` |
| Git tag | `v1.0.0`（commit `982824f`） |
| 提交审核 | 2026-11-02 |
| 当前状态 | **2026-11-03 收到 Guideline 2.1 补件要求**；补录屏与说明后重新提交同一构建（尚未上架） |
| 支持设备 | iPad（iPadOS 17+） |
| 价格 | 免费 |
| Bundle ID | `com.hmh.nook` |

> 这是产品的首个公开版本，也是从原名 Nook 更名后的首个版本。App Store 上的名称：中文「知栈」，英文「KnowStack」。

---

## 中文发布说明

### 新功能

- **多级文件夹**：像电脑一样新建、重命名、移动、排序；文件按真实目录保存。
- **标签与组合筛选**：一份资料可打多个标签，按「文件夹 + 标签 + 关键词」筛选。
- **全文检索**：文件名与 PDF / HTML 正文建立索引，按内容定位资料。
- **PDF 标注**：调用系统预览，支持手写、形状、签名；保存回原文件。
- **图片与网页课件预览**：图片可标注，HTML 在 App 内渲染。
- **分享扩展**：从其他 App 通过系统分享面板存入「知栈」。
- **iCloud 与「文件」App**：资料以真实文件保存，可在「文件」App 浏览；登录 iCloud 后多设备同步。
- **中英文界面**：跟随系统语言切换，中文显示「知栈」，英文显示「KnowStack」。

### 改进

- 适配 iPad 横屏；资料网格、侧栏与工具栏按 iPad 尺寸重新排布。
- PDF 打开时显示加载提示；文件只在 iCloud 上时先触发下载。
- 删除文件夹前检查子文件夹与文件，避免误删。
- 分享扩展、iCloud 容器与 App Group 配置整理完毕。

### 已知限制

- 扫描版 / 图片型 PDF 没有文字层，暂不支持 OCR，无法通过正文搜索。
- HTML 若引用外部网络资源，离线时部分内容可能无法显示。
- 暂未接入资料的「复制」与批量多选操作。
- 同步冲突按后写覆盖处理；未登录 iCloud 时仅本机可用。

### 兼容性

- 需要 iPadOS 17.0 或更高版本。
- 仅支持 iPad，不含 iPhone 版本。

---

## English Release Notes

### New

- **Nested folders** — create, rename, move and reorder; files are stored in real directories.
- **Tags and combined filters** — multiple tags per document, filtered by folder, tag and keyword.
- **Full-text search** — indexes file names plus the text inside PDFs and HTML.
- **PDF markup** — system preview for handwriting, shapes and signatures; saved in place.
- **Image and web slide preview** — annotate images and render HTML inside the app.
- **Share extension** — save files from any app into KnowStack.
- **iCloud and Files** — real documents, visible in Files; sync across devices when signed in to iCloud.
- **Chinese and English UI** — follows the system language. 知栈 in Chinese, KnowStack in English.

### Improvements

- Landscape iPad layout across the library, sidebar and toolbars.
- Loading feedback while opening PDFs; triggers iCloud download when needed.
- Safer folder deletion with nested content checks.
- Share extension, iCloud container and App Group configuration cleaned up.

### Known limitations

- Scanned or image-only PDFs have no text layer; OCR is not supported yet.
- HTML that references external resources may render partially offline.
- Copy and multi-select for documents are not available yet.
- Sync conflicts are last-write-wins; without iCloud, data stays on one device.

### Compatibility

- Requires iPadOS 17.0 or later.
- iPad only; no iPhone version.

---

## 2026-11-03 · App Review 2.1 补件

- 苹果要求：真机屏幕录制 + 6 项说明（用途/受众、设置步骤、外部服务、地区差异、监管/第三方素材）。
- 处理：未改代码；已准备 [App Review 补件说明](app-review-response.md)、录制脚本与[示例文件](https://gheminghui.github.io/Nook/review/samples.zip)。
- 下一步：录制真机视频 → 粘贴 Notes → 重新提交 `1.0 (1)`。

## 审核通过与上线后要做的验证

- [ ] App Store 页面名称、副标题、截图与描述正确
- [ ] 从 App Store 安装，首次启动无崩溃
- [ ] 导入 PDF / 图片 / HTML，预览与标注正常
- [ ] 分享扩展可从 Safari / 文件 App 存入
- [ ] 登录 iCloud 的设备间文件可见
- [ ] 支持页、隐私政策、营销页三个 URL 可访问
- [ ] 评分与评论入口正常

## 相关链接

- 营销页：https://gheminghui.github.io/Nook/
- 支持页：https://gheminghui.github.io/Nook/support.html
- 隐私政策：https://gheminghui.github.io/Nook/privacy.html
- 提交清单：`assets/appstore/SUBMISSION_CHECKLIST.md`
- 部署与回滚：`03-operations/deploy.md`

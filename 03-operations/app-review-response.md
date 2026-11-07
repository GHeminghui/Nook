# App Review 2.1 补件说明（知栈 / KnowStack 1.0）

> 状态：2026-11-03 收到 Guideline 2.1 - Information Needed，非代码问题，补录屏 + 说明后重新提交。
> 关联：`release-notes.md`、`deploy.md`、`assets/appstore/SUBMISSION_CHECKLIST.md`

## 1. 苹果要的是什么

这是 **2.1 Information Needed**，不是功能缺陷，也不是被拒死。它要求：

1. 一台**真机**、最新系统上的**屏幕录制**，从启动 App 开始，展示典型流程；
2. App 的用途、目标用户、解决的问题和价值；
3. 如何设置并访问主要功能（需要的话给测试账号或样例文件）；
4. 使用的外部服务/平台；
5. 不同地区是否有功能差异；
6. 是否属于强监管行业、是否包含受保护的第三方素材。

我们的 App 没有账号、没有内购、没有社交/UGC 发布、没有第三方 SDK，所以第 1 项里的“账号删除 / 内容举报与拉黑 / 付费内容”都不适用，需要在 Notes 里明确说明。

## 2. 要不要重新上传构建？

- **只补 Notes + 录屏链接：不需要新构建**，在 ASC 里改 App Review Information 后重新提交同一个 `1.0 (1)` 即可。
- 如果顺手改了代码或修了 bug：构建号 +1（`1.0 (2)`），重新 Archive 上传，再提交。
- 不要为了补说明而改代码；苹果这次问的是信息。

## 3. 录屏怎么录

### 3.1 准备

- 用**物理 iPad**（不要模拟器），系统尽量升到最新 iPadOS；
- 安装 **TestFlight 里的 1.0 (1)**，或 Xcode 的 Release 构建；
- 把 [samples.zip](https://gheminghui.github.io/Nook/review/samples.zip) 解压到「文件」App 的「我的 iPad」；
- 打开「勿扰模式」，清空通知；使用演示数据，不要出现真实学生姓名；
- 建议把系统语言切到 **English**，App 会显示 KnowStack，审核员更容易看懂；如果想展示中文，也可以，但 Notes 用英文写清楚；
- 录制前先自己完整走一遍，确认不闪退。

### 3.2 录制方式

iPad 控制中心 → 屏幕录制（可不开麦克风）→ 回到主屏幕 → 开始操作 → 停止后保存到「照片」。

导出到 Mac 后建议压到 1080p 或 720p，控制在 100 MB 以内。

### 3.3 建议脚本（约 3 分钟）

> 逐步骤、带按钮名和时间点的版本见 [review-recording-script.md](review-recording-script.md)，可以直接照着做。


| 时间 | 操作 | 展示点 |
|---|---|---|
| 0:00 | 主屏幕，点「知栈 / KnowStack」图标 | 从启动开始 |
| 0:10 | 启动后展示「全部资料 / All Materials」 | 空资料库与整体布局 |
| 0:20 | 侧栏 `+` 新建文件夹：Math → Grade 10 → Functions | 多级文件夹 |
| 0:40 | 点右上角「导入 / Import」，选 samples 里的 PDF、HTML、PNG | 导入三种格式 |
| 1:00 | 导入后的批量标签面板，新建 `Key`、`Review`、`Mistake` | 标签与批量打标签 |
| 1:20 | 长按资料 → 编辑标签 / 移动到… | 资料管理 |
| 1:35 | 搜索 `functions`；点标签筛选 | 全文搜索 + 标签组合 |
| 1:55 | 点 PDF → 系统预览 → 标记 → 手写/高亮/签名 → 完成 → 重新打开 | PDF 标注保存 |
| 2:30 | 返回，点 HTML → 页面渲染 | 网页课件预览 |
| 2:45 | 打开「文件」App，从共享面板把另一个文件存入 KnowStack | 分享扩展 |
| 3:00 | 回到 App，展示新文件 | 收资料闭环 |
| 3:10 | 停止录制 | 结束 |

> 不必展示 iCloud 登录；如果设备已登录 iCloud，可以顺带展示文件出现在「文件」App 的 KnowStack 文件夹里，但不强求。

### 3.4 录屏放哪里

推荐二选一：

1. **YouTube / Vimeo 不公开链接**：上传后设为「不公开 / 任何知道链接的人可看」，不要设私密；
2. **直接 MP4 托管在 GitHub Pages**（更稳，审核员不用登录）：
   - 把文件放到 `assets/appstore/site/review/demo.mp4`；
   - 重新发布 `gh-pages`；
   - 链接：`https://gheminghui.github.io/Nook/review/demo.mp4`；
   - 单文件要小于 100 MB，建议 720p。

不要用需要登录的网盘链接；提交前用无痕窗口打开一次，确认不需要账号。

## 4. App Review Information · Notes（直接粘贴）

> 把 `[RECORDING URL]`、`[iPad model]`、`[iPadOS version]` 换成实际值；其余可以原样使用。

```
Hello App Review Team,

Thank you for the Guideline 2.1 request. Below is the requested information for KnowStack (知栈) 1.0 (1).

1) Screen recording (physical iPad, latest iPadOS)
[RECORDING URL]

The recording starts by tapping the app icon and shows the typical flow: launch, create nested folders, import a PDF/HTML/PNG, add tags, search and filter, open and mark up a PDF in the system preview, render an HTML slide, and save a file through the share extension.

The recording shows, in order: launching the app and the empty library; creating the Math / Grade 10 / Functions folders; importing the sample PDF, HTML and PNG; adding the Key and Review tags; search and tag filtering; PDF markup in the system preview; HTML preview; and saving a file through the share extension.

2) Purpose and audience
KnowStack is a local-first study materials library for iPad. It is built for teachers, students and parents. The problem: lesson slides, exams, mistake logs and web pages are scattered across chats, cloud drives and photo albums. The value: nested folders, tags, full-text search, system PDF markup and a share extension keep materials organized and findable.

3) Setup and access
No account, login or credentials are required. The library is empty on first launch.
- Sample files: https://gheminghui.github.io/Nook/review/samples.zip
- Unzip and place the files in Files (On My iPad).
- Tap Import (top right) and select the PDF, HTML and PNG.
- Use + in the sidebar to create folders and tags; long-press an item to tag, rename or move it.
- Search for "functions" to see full-text search.
- Tap the PDF to open the system preview and try markup.

4) External services and platforms
Only Apple system services and frameworks: iCloud Documents (the user's own iCloud Drive, optional), PDFKit/Quick Look, WebKit, SwiftData, UIKit/SwiftUI and the system share sheet. There are no third-party servers, SDKs, analytics, advertising, AI or payment services.

5) Regional differences
None. All features are available in every region. iCloud sync depends on the user's Apple ID and iCloud availability; without iCloud, the app works locally.

6) Regulated industry / third-party material
Not a regulated industry. The app ships no third-party content; it only displays files the user imports. The sample files linked above were created by us for review and contain no third-party material.

Additional notes:
- No account creation, so there is no account deletion flow.
- No social or community features. Imported files stay on the user's device or in the user's own iCloud and are not published to other users, so content reporting and blocking do not apply.
- No paid content or in-app purchases.
- Tested on [iPad model], iPadOS [iPadOS version].

Please let us know if you need any further information.
```

## 5. Resolution Center 回复（可选，提交时一起发）

```
Hello App Review Team,

Thank you for the Guideline 2.1 feedback. We have added all requested information to the App Review Information Notes field, including a screen recording captured on a physical iPad, the app's purpose and audience, setup instructions with sample files, the external services used, regional differences, and confirmation that the app is not in a regulated industry and ships no third-party content.

No account or demo credentials are required. Please let us know if anything else is needed.
```

## 6. 重新提交前检查

- [ ] 录屏是在物理 iPad 上录的，从点图标启动开始
- [ ] 录屏链接在无痕窗口可打开，不需要登录
- [ ] 示例文件链接可下载：https://gheminghui.github.io/Nook/review/samples.zip
- [ ] Notes 里 6 项都有，且没有 `[RECORDING URL]` 这类占位符
- [ ] 明确写了「无账号 / 无内购 / 无社交 UGC / 无第三方 SDK」
- [ ] 真机完整走一遍：启动 → 导入 → 标签 → 搜索 → PDF 标注 → HTML → 分享扩展
- [ ] 如果代码有改动，构建号已 +1 并重新上传；只改 Notes 则不用新构建
- [ ] 重新提交后，在 Resolution Center 同步回复

## 7. 相关链接

- 示例文件：https://gheminghui.github.io/Nook/review/samples.zip
- 营销页：https://gheminghui.github.io/Nook/
- 支持页：https://gheminghui.github.io/Nook/support.html
- 隐私政策：https://gheminghui.github.io/Nook/privacy.html
- 提交清单：`assets/appstore/SUBMISSION_CHECKLIST.md`

# ADR-003：用 String Catalog 管理中英文本地化

- **状态**：已采纳
- **日期**：2026-11-01
- **决策者**：Jony

## 背景

Nook 的界面文案此前全部硬编码为简体中文。App Store 需要 en-US 本地化，且后续还要继续迭代界面；如果每加一条文案都要手工同步多个 `.strings` 文件，漏翻和 key 漂移会很难发现。

工程使用 Xcode 27、iOS 17+，SwiftUI 的 `Text` / `Button` / `Label` 等默认按 `LocalizedStringKey` 查找资源，适合用字符串目录统一管理。

## 决策

- 使用 **String Catalog**（`Localizable.xcstrings`）作为唯一文案资源：
  - `Nook/Localizable.xcstrings`：App 主目标，74 条；
  - `NookShare/Localizable.xcstrings`：分享扩展，3 条。
- 源语言为 **简体中文**，同时提供 **英文** 翻译；Xcode 编译出 `zh-Hans.lproj` 与 `en.lproj`，界面跟随系统语言。
- 静态文案保留中文字面量，由 SwiftUI 自动按 key 查找；动态文案（数量、路径、扩展名）改用 `String(format: String(localized: "..."), value)`，避免依赖 SwiftUI 自动生成的插值 key。
- 取不到资源时回退到中文 key，保证中文环境不会出现空白。

## 备选方案

| 方案 | 优点 | 缺点 |
|------|------|------|
| 每个语言一份 `.strings` | 兼容老系统、可读性好 | 多处维护、key 易漂移、无翻译状态视图 |
| 代码内字典（`L10n`） | 零资源文件、测试简单 | 非平台惯例，无法被 Xcode 提取/校对，App Store 语言声明不完整 |
| String Catalog（采纳） | 单文件、Xcode 原生、可标翻译状态、自动编译多语言 | 新增文案需手工确认，运行时拼接的 key 不会被自动提取 |

## 后果

- **正面影响**：中英文界面统一维护；Xcode 可直接看到哪些条目未翻译；App Store 可声明 zh-Hans / en-US 两套本地化。
- **负面影响**：新增硬编码文案时，Xcode 不会自动写入翻译，需要在目录中补条目；动态拼接的 key 必须显式登记。
- **后续动作**：
  - 新增界面文案时同步更新 `Localizable.xcstrings`；
  - 如需更多语言，在目录中增加对应 locale，不改代码；
  - 截图与文案中的演示数据仍是中文，正式面向英文市场时可再做数据本地化。

## 相关链接

- `02-development/src/Nook/Localizable.xcstrings`
- `02-development/src/NookShare/Localizable.xcstrings`
- `assets/appstore/README.md`

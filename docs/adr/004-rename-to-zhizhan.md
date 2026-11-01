# ADR-004：App 更名为「知栈 / KnowStack」

- **状态**：已采纳
- **日期**：2026-11-01
- **决策者**：Jony

## 背景

App 原名 **Nook**。在 App Store Connect 创建版本时，名称 `Nook` 已被占用，无法提交。

进一步看，`Nook` 同时是 **Barnes & Noble NOOK** 的品牌，且 NOOK 本身就是阅读类应用，与本产品（学习资料库/PDF 阅读标注）品类相近。即使通过加后缀绕过重名检查，仍可能在 App Review 阶段触发指南 5.2.1（知识产权）问题。

## 决策

整体更名，不保留 Nook：

- 中文名：**知栈**
- 英文名：**KnowStack**
- App Store 中文名「知栈」，英文区名称「KnowStack」
- 主屏幕显示名通过 `InfoPlist.strings` 本地化：简体中文「知栈」，英文「KnowStack」
- 分享扩展显示名：「存入知栈」/「Save to KnowStack」
- Bundle ID 保持 `com.hmh.nook` 不变，App Store 记录可原地改名称，不需新建 App

## 备选方案

| 方案 | 优点 | 缺点 |
|------|------|------|
| 保留 Nook，加后缀（Nook 学习资料库） | 改动最小，可能通过重名检查 | Barnes & Noble NOOK 商标风险，审核 5.2.1 可能被拒 |
| 资料匣 / DocCase | 含义直白 | 品牌感弱，偏描述性 |
| 页仓 / PageCang | 收纳感强 | 英文名不够自然 |
| 知栈 / KnowStack（采纳） | 两字好记、分层收纳含义、中英文均无同名 App | 国内有“知栈宿联”（民宿），品类不同 |

## 后果

- **正面影响**：名称可用性风险解除；品牌更贴合“资料分层收纳”；中英文名都短且可读。
- **负面影响**：此前的 Nook 品牌、截图、站点文案、分享扩展文案都要同步修改；已存在的 iCloud 容器名改为「知栈」只影响显示名，底层容器 ID 不变。
- **后续动作**：
  - 截图与元数据全部按新名称重新生成；
  - 站点文案更新后重新发布；
  - App Store Connect 中修改名称后重新提交；
  - 若未来做商标注册，建议查 9/42 类。

## 相关链接

- `02-development/src/Nook/Localizable.xcstrings`
- `02-development/src/Nook/InfoPlist.strings`（`en.lproj` / `zh-Hans.lproj`）
- `assets/appstore/metadata/zh-Hans.md`
- `assets/appstore/metadata/en-US.md`

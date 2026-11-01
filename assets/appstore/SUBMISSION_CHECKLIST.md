# 知栈 / KnowStack · App Store 提交清单

> 生成日期：2026-11-01　适用版本：1.0 (1)　Bundle ID：`com.hmh.nook`（不变）
> 状态：**已提交审核（2026-11-02，构建 1.0 (1)，git tag `v1.0.0`）**。本清单保留，供后续版本或回退时对照。
>
> 说明：这是「照着填」的清单，**带 [x] 的已经做完并验证过**，带 [ ] 的需要你在 App Store Connect 或 Xcode 里操作。

---

## 0. 一句话状态

| 项目 | 值 |
|---|---|
| App 名称（zh-Hans） | 知栈 |
| App 名称（en-US） | KnowStack |
| 副标题（zh-Hans） | 高效学习资料分类管理 |
| 副标题（en-US） | Organize study materials fast |
| Bundle ID | `com.hmh.nook` |
| Share Extension | `com.hmh.nook.NookShare` |
| 开发团队 | `D9RDFJAM6W` |
| 版本 / 构建号 | `1.0` / `1` |
| 设备 | 仅 iPad（TARGETED_DEVICE_FAMILY = 2） |
| 最低系统 | iPadOS 17.0 |
| 价格 | 免费（待你确认） |
| 主要分类 | 教育 |
| 次要分类 | 效率 |
| 年龄分级 | 4+ |
| 隐私 | 不收集数据（Data Not Collected） |
| 支持网址 | https://gheminghui.github.io/Nook/support.html |
| 隐私政策 | https://gheminghui.github.io/Nook/privacy.html |
| 联系邮箱 | minghuihe2022@163.com |
| 版权 | © 2026 知栈 · KnowStack |

---

## 1. 提交前技术自检（Xcode 侧）

- [x] App 名称、显示名、App 内标题、分享扩展文案已改为知栈 / KnowStack
- [x] 中英文 `InfoPlist.strings` 已编译进包（`zh-Hans.lproj` / `en.lproj`）
- [x] 全量测试通过：46 项，45 通过，1 跳过（截图用例），0 失败
- [x] 图标：1024×1024、无 alpha（`assets/appstore/final/icon/icon-1024.png`）
- [x] 截图：中英文各 5 张，2752×2064、无 alpha
- [x] 已加 `ITSAppUsesNonExemptEncryption = false`
- [x] 已移除无关的 `group.com.hmh.MacArchiver` 授权（只保留 `group.com.hmh.app`）
- [ ] 用 **Generic iOS Device** 做 `Product → Archive`（不要用模拟器）
- [ ] Archive 后点 **Validate App**
- [ ] 确认 App ID `com.hmh.nook` 已开启：**iCloud Documents** + **App Groups**
- [ ] 确认 App Group `group.com.hmh.app` 在开发者账号中存在
- [ ] 确认 iCloud 容器 `iCloud.com.hmh.nook` 在开发者账号中存在
- [ ] 确认签名团队为 `D9RDFJAM6W`，使用自动签名
- [ ] 确认版本号 `1.0`、构建号 `1`（上传后不可复用同一个构建号）
- [ ] 确认 Release 包不包含演示数据（`DemoData.swift` 仅在 `#if DEBUG` 编译）
- [ ] 确认没有占位符：邮箱、URL、示例文案

> 如果 Archive 报 iCloud/App Group 权限错误，先到 [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list) 给 `com.hmh.nook` 勾上对应能力，再重新下载描述文件。

---

## 2. App Store Connect · App 信息

路径：**App Store Connect → 我的 App → 知栈 → App 信息**

| 字段 | 填什么 |
|---|---|
| 名称 | `知栈`（英文区：`KnowStack`） |
| 副标题 | `高效学习资料分类管理`（英文区：`Organize study materials fast`） |
| 主要语言 | 简体中文 |
| Bundle ID | `com.hmh.nook`（下拉选择，不要新建） |
| SKU | 建议 `ZHIZHAN-001`（内部用，提交后不可改，自己定一个稳定的） |
| 用户访问权限 | 限制访问（如无团队需求） |
| 内容版权 | 不包含第三方内容（App 只展示用户自己导入的文件） |

> 如果 `知栈` 保存时提示被占用：按顺序试 **资料匣** → **页仓**；名字一改，截图和元数据也要同步改，告诉我即可。

---

## 3. 版本信息（1.0）

路径：**App Store Connect → 版本 → 1.0 准备提交**

### 3.1 中文（zh-Hans）

| 字段 | 值 |
|---|---|
| 推广文本 | 课件、试卷、错题和网页素材，收进一个地方。多级文件夹、标签、全文搜索，PDF 直接在系统预览里标注。 |
| 描述 | 见 `assets/appstore/metadata/zh-Hans.md` 的「描述」代码块，整段复制 |
| 关键词 | 学习资料,资料库,课件,试卷,错题,笔记,归档,文件夹,标签,搜索,PDF,标注,教学,老师,学生 |
| 支持网址 | https://gheminghui.github.io/Nook/support.html |
| 营销网址（可选） | https://gheminghui.github.io/Nook/ |
| 版权 | © 2026 知栈 · KnowStack |

### 3.2 英文（en-US）

| 字段 | 值 |
|---|---|
| 推广文本 | A local-first library for slides, exams and notes. Nested folders, tags, full-text search, and PDF markup with the system preview. |
| 描述 | 见 `assets/appstore/metadata/en-US.md` 的 Description 代码块，整段复制 |
| 关键词 | study library,notes,pdf,slides,exam,organizer,folders,tags,search,annotate,teacher,student |
| 支持网址 | https://gheminghui.github.io/Nook/support.html |
| 营销网址（可选） | https://gheminghui.github.io/Nook/ |
| 版权 | © 2026 知栈 · KnowStack |

> 本地化：在版本页左侧「语言」里添加 **English (U.S.)**，名称填 `KnowStack`、副标题填 `Organize study materials fast`，再上传英文截图。

---

## 4. 截图（必传）

路径：**版本页 → App 截图 → iPad 13"**

| 顺序 | 中文文件 | 英文文件 |
|---|---|---|
| 1 | `assets/appstore/final/screenshots/zh-Hans/01.png` | `assets/appstore/final/screenshots/en-US/01.png` |
| 2 | `.../zh-Hans/02.png` | `.../en-US/02.png` |
| 3 | `.../zh-Hans/03.png` | `.../en-US/03.png` |
| 4 | `.../zh-Hans/04.png` | `.../en-US/04.png` |
| 5 | `.../zh-Hans/05.png` | `.../en-US/05.png` |

- 规格：**2752 × 2064**，横屏，无 alpha，已套 Apple 官方 iPad Pro (M5) 边框
- 顺序：全部资料 → 文件夹层级 → PDF 标注 → 标签筛选 → 网页课件
- App 预览视频：不做（可选）
- 不需要 iPhone 截图（App 仅 iPad）

> 如果 ASC 提示尺寸不符，确认上传的是 `final/screenshots` 下的成品，不是 `raw/` 或 `mockups/`。

---

## 5. App 隐私

路径：**App 隐私 → 开始**

| 问题 | 回答 |
|---|---|
| 是否收集数据？ | **否，我们不收集数据** |
| 是否用于跟踪？ | 否 |
| 第三方 SDK | 无 |
| 隐私政策网址 | https://gheminghui.github.io/Nook/privacy.html |

说明口径（如果审核问起）：

> App 不收集任何个人信息，无账号、无广告、无分析 SDK。用户导入的文件只保存在设备沙盒；开启 iCloud 时保存于用户自己的 iCloud Drive，开发者无法访问。

---

## 6. 年龄分级

路径：**年龄分级 → 编辑**

- 所有内容项选「无 / 否」
- 结果应为 **4+**
- 不勾选「 Made for Kids」

---

## 7. 定价与销售范围

路径：**定价与销售范围**

- 价格：**免费**（如果你要收费，改这里）
- 销售范围：所有国家/地区；**中国大陆**需要 **ICP 备案号**
- 如果还没有 App 备案号：先取消勾选「中国大陆」，其余地区可正常上架
- 税务类别：按你的账号设置（个人开发者一般选默认）

---

## 8. App 审核信息

路径：**App 审核 → 联系信息 / 备注**

| 字段 | 填什么 |
|---|---|
| 联系人 | Jony |
| 电话 | **待你填写**（必须能联系到） |
| 邮箱 | minghuihe2022@163.com |
| 演示账号 | 不需要（App 无需登录） |
| 备注 | 见下方 |

审核备注（直接复制）：

```
App 为 iPad 专用，无需登录，也没有演示账号。

测试路径：
1. 启动后是「全部资料」列表，右上角「导入」可从「文件」选择 PDF / 图片 / HTML；
2. 长按资料可重命名、编辑标签、移动到其他文件夹、删除；
3. 点击 PDF 会打开系统预览，右上角标记按钮可手写 / 形状 / 签名；
4. 点击 HTML 会在 App 内渲染网页；
5. 侧栏可新建文件夹与标签，支持多级嵌套。

App 不含账号、广告、内购或第三方分析 SDK。iCloud 同步需要设备登录 iCloud 后才会启用；未登录时数据仅保存在本机。
```

---

## 9. 出口合规

- App 未使用自定义加密，仅使用系统 HTTPS / iCloud。
- Info.plist 已设置 `ITSAppUsesNonExemptEncryption = false`。
- ASC 里如果仍问「是否使用加密」，选 **否 / 仅使用系统加密**。

---

## 10. 构建与提交

- [ ] Xcode → Product → Archive
- [ ] Organizer → Distribute App → App Store Connect → Upload
- [ ] 等待 ASC 处理完成（通常 5–15 分钟）
- [ ] 版本页 → 构建版本 → 选择 `1.0 (1)`
- [ ] 检查所有字段、截图、隐私、年龄分级
- [ ] 点「添加以供审核」
- [ ] 发布方式建议选 **手动发布**（审核通过后自己点上线）
- [ ] 提交前先用 TestFlight 自己装一遍，确认启动、导入、PDF 标注、分享扩展

---

## 11. 提交后 / 回退

- 审核被拒最常见原因：
  1. 名称/商标（知栈如果被异议）→ 换备用名；
  2. 隐私政策打不开 → 检查 GitHub Pages；
  3. 截图与实际界面不一致 → 当前截图是真实界面，风险低；
  4. 记者问「文件管理为什么需要 iCloud」→ 审核备注已说明。
- 名称备用顺序：**资料匣** → **页仓**。
- 构建号：每次重新上传都要把 `CURRENT_PROJECT_VERSION` +1（1 → 2 → 3），版本号 `1.0` 不变。

---

## 12. 当前仍未完成

- [ ] App 审核联系电话
- [ ] 中国大陆 ICP 备案号（如要上中国区）
- [ ] App Store Connect 里把名称改成知栈并保存成功
- [ ] 本地改动提交到 `main`（本地化、改名、截图、站点、元数据）
- [ ] `PROJECT_STATE.json` 仍停在开发阶段；上架材料属于运营阶段，建议提交前运行 `/advance`

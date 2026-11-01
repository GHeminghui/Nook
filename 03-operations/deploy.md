# 知栈 v1.0.0 · 部署与发布方案

> 版本：`1.0 (1)`　代码 tag：`v1.0.0`（commit `982824f`）　提交审核：2026-11-02
> 形态：iPad 原生 App（含分享扩展）+ 静态站点；**没有自建后端**，数据在设备与用户自己的 iCloud Drive。

## 1. 发布对象

| 组件 | 位置 | 说明 |
|---|---|---|
| 主 App | `com.hmh.nook` | iPadOS 17+，iPad only |
| 分享扩展 | `com.hmh.nook.NookShare` | 随主 App 一起打包 |
| 营销页 | `assets/appstore/site/index.html` | GitHub Pages `/Nook/` |
| 支持页 | `assets/appstore/site/support.html` | GitHub Pages `/Nook/support.html` |
| 隐私政策 | `assets/appstore/site/privacy.html` | GitHub Pages `/Nook/privacy.html` |
| App Store 素材 | `assets/appstore/final/` | 图标 + 中英文截图 |
| 元数据 | `assets/appstore/metadata/` | 名称、副标题、描述、关键词、审核备注 |

## 2. 前置条件

- [x] 开发者团队 `D9RDFJAM6W`，App ID `com.hmh.nook` 已开启 iCloud Documents + App Groups
- [x] iCloud 容器 `iCloud.com.hmh.nook` 已注册
- [x] App Group `group.com.hmh.app` 已注册，主 App 与分享扩展都已勾选
- [x] 签名方式：Automatic
- [x] 版本 `MARKETING_VERSION = 1.0`，`CURRENT_PROJECT_VERSION = 1`
- [x] 全量测试通过（46 项，45 通过 / 1 跳过 / 0 失败）
- [x] 截图、元数据、站点已就绪
- [ ] App Store Connect 里已把名称保存为「知栈」（英文区 KnowStack）
- [ ] 审核联系电话、中国大陆 ICP 备案号（如适用）

## 3. 构建与上传

```bash
cd 02-development

# 1. 模拟器全量回归（可选但建议）
xcodebuild test \
  -project src/Nook.xcodeproj -scheme Nook \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5)' \
  -resultBundlePath /tmp/nook-release.xcresult

# 2. Archive（必须 generic iOS device，不要选模拟器）
xcodebuild archive \
  -project src/Nook.xcodeproj -scheme Nook \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath /tmp/Nook-1.0.0.xcarchive
```

然后在 Xcode **Organizer → Distribute App → App Store Connect → Upload**。

上传前确认：

- [ ] 包内 `CFBundleDisplayName` 为「知栈」，英文环境为「KnowStack」
- [ ] `ITSAppUsesNonExemptEncryption = false`
- [ ] entitlements 只含 `group.com.hmh.app` 与 `iCloud.com.hmh.nook`
- [ ] Release 包不含 `DemoData` 演示数据（仅 `#if DEBUG`）
- [ ] 构建号未使用过（重新上传要 +1）

## 4. App Store Connect 配置

按 [提交清单](../assets/appstore/SUBMISSION_CHECKLIST.md) 逐项填写：

1. App 信息：名称、副标题、SKU、分类、版权；
2. 版本信息：描述、关键词、推广文本、支持/营销 URL；
3. 截图：中文 5 张 + 英文 5 张（2752×2064）；
4. App 隐私：不收集数据；
5. 年龄分级：4+；
6. 审核备注：无需登录、iPad only、测试路径；
7. 构建版本：选择刚刚上传的 `1.0 (1)`。

## 5. 发布策略

- 首次发布建议 **手动发布**：审核通过后先自己用 TestFlight/商店版本验证，再点「发布」。
- 如使用分阶段发布（Phased Release），7 天内逐步放量；出现严重问题时可以 **暂停** 分阶段发布。
- 发布后 24 小时重点观察：崩溃、评分、邮件反馈。

## 6. 回滚方案

App Store 不能回滚二进制，只能「下架 + 发修复版」。按严重程度：

### 6.1 审核阶段被拒

1. 在 ASC 查看 Resolution Center 的具体条款；
2. 修复后构建号 +1，重新上传；
3. 在审核备注里说明修改点；
4. 代码打新 tag（如 `v1.0.0-build2`），不要复用 `v1.0.0`。

### 6.2 已上线但发现严重问题

1. **暂停分阶段发布**（如果还在放量）；
2. ASC → App 信息 → **从销售中移除**（Remove from Sale），阻止新用户下载；
3. 修复后提交加急审核（Expedited Review），构建号 +1；
4. 新版本通过后重新上架；
5. 在支持页/邮件里告知已受影响用户。

### 6.3 站点回滚

```bash
# 在 gh-pages 的临时 clone 中
git log --oneline -5
git revert <bad-commit>
git push origin gh-pages
```

或检出上一个正常 commit 后强制推送（仅限确认历史干净时）：

```bash
git reset --hard <good-commit>
git push --force origin gh-pages
```

### 6.4 代码回滚

- 不移动已发布 tag；用 `git revert` 生成反向提交，再打新 tag；
- 数据库/文件格式若变更，必须保证旧版本能读新数据，否则不要回退 App 版本。

## 7. 版本号与 tag 规范

| 场景 | App Store 版本 | 构建号 | Git tag |
|---|---|---|---|
| 首次提交 | 1.0 | 1 | `v1.0.0` |
| 同一版本重修 | 1.0 | 2 | `v1.0.0-build2` |
| 功能修复发布 | 1.0.1 | 3 | `v1.0.1` |
| 较大版本 | 1.1 | 4 | `v1.1.0` |

- tag 一旦推送不要移动；
- 每次上传构建号必须递增；
- 发布说明放 `03-operations/release-notes.md`。

## 8. 联系人与依赖

| 事项 | 负责/依赖 |
|---|---|
| App Store 提交与回复审核 | Jony / minghuihe2022@163.com |
| 开发者账号与证书 | 团队 `D9RDFJAM6W` |
| iCloud / App Group | Apple Developer Portal |
| 站点托管 | GitHub Pages（`gh-pages` 分支） |
| 用户数据 | 用户设备 / 用户自己的 iCloud，开发者不可访问 |

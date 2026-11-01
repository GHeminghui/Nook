# 知栈 · 运维手册（Runbook）

> 适用版本：1.0.x　最后更新：2026-11-02
> 配套：`deploy.md`（发布/回滚）、`monitoring.md`（监控）、`release-notes.md`（发布说明）

## 1. 系统概览

| 组件 | 运行位置 | 失败影响 |
|---|---|---|
| 主 App | 用户 iPad | 无法打开资料库 / 预览 / 标注 |
| 分享扩展 | 用户 iPad | 其他 App 无法「存入知栈」 |
| iCloud Documents | 用户自己的 iCloud Drive | 多设备不同步；本地仍可用 |
| 静态站点 | GitHub Pages | 支持页/隐私政策/营销页打不开 |
| 开发者后台 | Apple Developer / ASC | 无法发版、查看崩溃/评论 |

没有自建服务器、数据库或账号系统；**开发者无法读取用户文件**。这意味着大多数用户数据问题只能由用户在设备上处理。

## 2. 日常检查

### 每日（上线首周）

- [ ] App Store Connect：审核状态、评分、评论、Resolution Center
- [ ] Xcode Organizer → Crashes：是否有新崩溃
- [ ] 支持邮箱：是否有集中反馈
- [ ] 站点三个 URL 是否 200：`/`、`/support.html`、`/privacy.html`

### 每周

- [ ] 崩溃趋势（Crash-free sessions）
- [ ] 评论关键词：闪退 / 同步 / 搜索 / 标注
- [ ] iCloud 容器与 App Group 是否仍正常（新增设备测试）
- [ ] 依赖：iOS/iPadOS 新版本是否引入回归

## 3. 常见问题与处理

### 3.1 App 启动即闪退

1. 让用户升级到最新版本；
2. 从 Xcode Organizer 或 ASC 拉取崩溃日志，确认是否为 SwiftData `ModelContainer` 初始化失败；
3. 若是数据模型迁移问题：让用户先通过「文件」App 备份 Nook 文件夹，再删除/重装 App；
4. 复现后修复，构建号 +1，走加急审核。

### 3.2 PDF 打不开 / 一直「正在打开…」

- 确认文件是否只在 iCloud、尚未下载到本地：让用户联网后重试；
- 在「文件」App → Nook 中确认文件存在、大小正常；
- 若是扫描件过大，Quick Look 首帧可能较慢，等待 5–10 秒；
- 仍失败：让用户导出该文件到「文件」App 再重新导入，排除文件损坏。

### 3.3 搜索不到内容

- 确认是**扫描版 PDF**：没有文字层，当前不支持 OCR，属已知限制；
- HTML 外部资源不影响正文索引，但图片内容不会被检索；
- 让用户用文件名关键词验证索引是否工作。

### 3.4 iCloud 不同步

1. 设置 → Apple ID → iCloud → iCloud Drive 已开启；
2. 设置 → 通用 → iPad 储存空间 → 知栈，确认 iCloud 开关；
3. 设备联网，低电量模式可能延迟同步；
4. 在「文件」App → iCloud Drive → 知栈 查看文件是否已上传；
5. 仍未同步：关闭再开启 iCloud 开关，重启设备；不要删除本地文件。

### 3.5 分享扩展不显示 / 存入失败

- 分享面板左滑 → 更多 → 打开「存入知栈」；
- 确认主 App 已至少启动过一次；
- 重启设备后再试；
- 若扩展闪退：查看 Console 中 `NookShare` 进程日志，确认 App Group 容器可写。

### 3.6 误删文件

- App 内删除会同时删磁盘文件，**没有回收站**；
- 若开启了 iCloud Drive：在「文件」App → 最近删除 中查找（通常保留 30 天）；
- 若未开启 iCloud：只能从用户自己的备份（iTunes/Finder/第三方）恢复；
- 不要建议用户「删除 App 重装」来恢复数据。

### 3.7 站点打不开

1. 打开 https://github.com/GHeminghui/Nook/deployments 查看 Pages 构建；
2. 检查 `gh-pages` 分支是否有最近提交；
3. 本地验证：

   ```bash
   for u in "" support.html privacy.html lang.js; do
     printf '%s ' "$u"; curl -s -o /dev/null -w '%{http_code}\n' \
       "https://gheminghui.github.io/Nook/$u"
   done
   ```

4. 回滚见 `deploy.md` 6.3。

## 4. 常用命令

### 4.1 构建与测试

```bash
cd 02-development

xcodebuild test \
  -project src/Nook.xcodeproj -scheme Nook \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5)' \
  -resultBundlePath /tmp/nook-runbook.xcresult

xcodebuild archive \
  -project src/Nook.xcodeproj -scheme Nook \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath /tmp/Nook.xcarchive
```

### 4.2 查看模拟器数据与日志

```bash
xcrun simctl get_app_container booted com.hmh.nook data
xcrun simctl spawn booted log stream --level debug \
  --predicate 'process == "Nook" OR process == "NookShare"'
```

### 4.3 检查描述文件里的能力

```bash
for f in "$HOME/Library/Developer/Xcode/UserData/Provisioning Profiles"/*.mobileprovision; do
  tmp=$(mktemp); security cms -D -i "$f" > "$tmp" 2>/dev/null
  if grep -q "group.com.hmh.app\|iCloud.com.hmh.nook" "$tmp"; then
    echo "== $f"; plutil -p "$tmp" | grep -E "group.com.hmh.app|iCloud.com.hmh.nook"
  fi
  rm -f "$tmp"
done
```

### 4.4 发布站点

```bash
rm -rf /tmp/nook-pages
git clone -q --branch gh-pages --depth 1 git@github.com:GHeminghui/Nook.git /tmp/nook-pages
cp -R assets/appstore/site/. /tmp/nook-pages/
cd /tmp/nook-pages
git add -A
git commit -m "chore: update site"
git push origin gh-pages
```

### 4.5 重新生成截图

见 `assets/appstore/README.md` 的「重新生成截图」，顺序是：

1. UI 测试生成原始截图（`TEST_RUNNER_CAPTURE_APPSTORE=1`）；
2. `tools/normalize.swift` 修正 EXIF 方向；
3. `tools/compose_device.swift` 套 Apple 官方边框；
4. `tools/render.sh` 渲染 2752×2064。

## 5. 事故分级

| 级别 | 例子 | 响应 |
|---|---|---|
| P0 | 启动即崩溃、数据丢失 | 立即暂停发布/下架，当天定位，加急审核 |
| P1 | PDF 打不开、分享扩展不可用 | 48 小时内修复，发补丁版 |
| P2 | 搜索不准、个别 HTML 显示异常 | 下一版本修复，支持页说明 |
| P3 | 文案/样式问题 | 随版本迭代 |

## 6. 升级与手记

- 每次事故处理后，在 `02-development/changelog.md` 记录原因与修复；
- 影响用户操作的变更，先更新支持页 FAQ；
- 不收集用户数据，排查时不要向用户索要含个人信息的原始文件；必要时让用户自行打码截图。

## 7. 联系人

| 事项 | 联系人 |
|---|---|
| 用户支持 / 审核 | Jony · minghuihe2022@163.com |
| 开发者账号 | 团队 `D9RDFJAM6W` |
| 站点 | GitHub `GHeminghui/Nook`（`gh-pages`） |

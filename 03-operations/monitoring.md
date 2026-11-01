# 知栈 · 监控方案（Monitoring）

> 适用版本：1.0.x　最后更新：2026-11-02
> 原则：**不引入第三方统计 SDK**，不收集用户数据；只用 Apple 自带数据 + 站点可用性 + 用户主动反馈。

## 1. 监控目标

| 目标 | 指标 | 数据来源 |
|---|---|---|
| 稳定性 | 崩溃次数、Crash-free sessions | Xcode Organizer / App Store Connect |
| 审核与上架 | 审核状态、被拒原因 | App Store Connect |
| 用户声音 | 评分、评论、邮件 | App Store / 支持邮箱 |
| 网站可用 | 三个 URL 的 HTTP 状态 | 手动或 UptimeRobot |
| 同步可用 | iCloud 容器/文件是否可见 | 真机抽测 |
| 发布回归 | 核心路径是否可用 | TestFlight + 真机清单 |

## 2. 日常节奏

### 上线后 7 天：每天一次（10 分钟）

- [ ] ASC → 状态是否变化（Waiting for Review / In Review / Ready for Sale）
- [ ] Xcode Organizer → Crashes：新增崩溃、影响设备数
- [ ] ASC → 评分与评论：是否有集中问题
- [ ] 邮箱：新反馈、是否需要当天回复
- [ ] 站点三个 URL 是否 200

### 上线 7 天后：每周一次

- [ ] 崩溃趋势与版本分布
- [ ] 评论关键词归纳（闪退 / 同步 / 搜索 / 标注 / 导入）
- [ ] 支持邮件归类，重复问题写进 FAQ
- [ ] 检查新 iOS/iPadOS 版本是否引入回归
- [ ] 备份：确认 `main` 与 tag 已推送

## 3. 关键指标与阈值

| 指标 | 正常 | 预警 | 处理 |
|---|---|---|---|
| Crash-free sessions | ≥ 99.5% | 99.0%–99.5% | 查 Top Crash，评估补丁版 |
| 单一崩溃影响设备 | < 1% | 1%–3% | 48 小时内修复 |
| 同一问题支持邮件 | 0–2 封/周 | ≥ 5 封/周 | 更新 FAQ；判断是否发版 |
| 站点可用性 | 100% | 任意一次 5xx | 查 GitHub Pages 构建/回滚 |
| 审核状态停滞 | < 3 天 | > 5 天 | 检查 Resolution Center / 联系审核 |

> 没有服务端指标（无后端），不要虚构 QPS、错误率等数据。

## 4. 各监控项怎么做

### 4.1 崩溃

1. Xcode → Window → Organizer → Crashes；
2. 选择「知栈」与版本 1.0 (1)；
3. 按设备数排序，点进堆栈；
4. 记录：崩溃函数、触发路径、影响设备数、系统版本；
5. 能在模拟器复现的，补一条回归测试再修。

### 4.2 评分与评论

- ASC → 我的 App → 评分与评论；
- 每周导出一次关键词；
- 不在评论里索要个人信息；需要排查时请用户发邮件。

### 4.3 支持邮箱

- 邮箱：minghuihe2022@163.com；
- 目标：24 小时内首次回复；
- 模板：

  ```
  你好，感谢反馈。请提供：
  1. iPad 型号与 iPadOS 版本
  2. 知栈版本（设置 → 通用 → iPad 储存空间 → 知栈）
  3. 复现步骤或录屏
  注意：不要发送包含个人信息的原始资料，截图前请打码。
  ```

### 4.4 站点

```bash
for u in "" support.html privacy.html lang.js index.html; do
  printf '%-16s ' "$u"
  curl -s -o /dev/null -w '%{http_code}\n' "https://gheminghui.github.io/Nook/$u"
done
```

期望全部 200。若要自动告警，可用 UptimeRobot 免费版监控：

- `https://gheminghui.github.io/Nook/`
- `https://gheminghui.github.io/Nook/support.html`
- `https://gheminghui.github.io/Nook/privacy.html`

告警发到 minghuihe2022@163.com。

### 4.5 iCloud 同步

每次发版前用两台设备抽测：

1. 设备 A 导入 PDF；
2. 等待 1–2 分钟；
3. 设备 B 打开「文件」App → 知栈，确认文件出现；
4. 在 App 内确认能看到并预览。

### 4.6 审核状态

- 提交后 24–72 小时通常有结果；
- 被拒：按 `deploy.md` 6.1 处理；
- 通过：按 `release-notes.md` 的上线验证清单逐项确认。

## 5. 告警与升级

| 事件 | 动作 |
|---|---|
| P0 崩溃/数据丢失 | 立即暂停分阶段发布，评估下架，走加急审核 |
| 站点 5xx 持续 10 分钟 | 检查 Pages 构建；回滚 `gh-pages` |
| 审核被拒 | 24 小时内读条款并回复/修改 |
| 同一问题 ≥5 封邮件/周 | 更新 FAQ，排入下个补丁版 |

升级路径：Jony（minghuihe2022@163.com）→ 判断是否发版 → 更新 `release-notes.md` 与支持页。

## 6. 隐私与合规

- 不接入 Firebase / Sentry / 友盟等第三方 SDK；
- 不记录用户文件内容、文件名、搜索词；
- 崩溃日志来自 Apple，开发者只能看到系统聚合信息；
- 用户主动发来的截图/文件，处理完即删除，不进入代码仓库；
- 隐私政策：https://gheminghui.github.io/Nook/privacy.html

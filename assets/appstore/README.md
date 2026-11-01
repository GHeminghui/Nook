# App Store 素材包 · 知栈 / KnowStack

> 生成日期：2026-11-01　设备：iPad 13 英寸横屏（2752 × 2064）　市场：zh-Hans + en-US
>
> 提交时按 [SUBMISSION_CHECKLIST.md](SUBMISSION_CHECKLIST.md) 逐项填写。

## 交付内容

```
assets/appstore/
  final/
    icon/icon-1024.png                  # 1024×1024，无 alpha
    screenshots/
      zh-Hans/01–05.png                 # 横屏成品，2752×2064
      en-US/01–05.png                   # 英文界面 + 英文标题
      raw/zh-Hans|en-US/01–05.png       # 原始截图（未套模板）
  metadata/
    zh-Hans.md                          # 名称 知栈 / 副标题「高效学习资料分类管理」
    en-US.md
  site/                                 # 营销首页 / privacy / support（中英文可切换）
  screenshots-landscape.html            # 横屏排版模板（中文）
  screenshots-landscape-en.html         # 横屏排版模板（英文）
  tools/normalize.swift                 # XCTest 截图 EXIF 方向归正
  tools/compose_device.swift            # 把截图放进 Apple 官方边框
  tools/render.sh                       # Chrome headless 渲染成品
  screenshots-landscape/zh|en/          # 原始横屏截图（未套边框）
  mockups/zh|en/                        # 套好 Apple 官方边框的设备图（3000×2300）
  templates/                            # Apple 官方 iPad Pro (M5) 边框 + 许可
```

截图顺序：全部资料 → 文件夹层级 → PDF 标注 → 标签筛选 → 网页课件预览。

设备边框使用 **Apple 官方 Apple Design Resources** 的 iPad Pro (M5) 13" Space Black 横屏 PNG（3000×2300，屏幕透明区正好 2752×2064），来源与许可见 `templates/README.md`。此前的手绘 CSS 边框和第三方模板已废弃。

## App 本地化

- 源语言：简体中文；新增 `02-development/src/Nook/Localizable.xcstrings`（74 条）与 `NookShare/Localizable.xcstrings`（3 条）。
- 英文翻译随系统语言自动切换；工程 `developmentRegion` 仍为 `en`，但两个语言资源都已编译进 App。
- 已验证：系统中文 → 中文界面；`-AppleLanguages (en)` → 英文界面（见 `raw/en-US` 截图）。
- 英文区截图的界面是英文，但演示资料的文件名/标签仍是中文——这是演示数据，不是未翻译的界面文案。

## 重新生成截图

需要 Xcode 27 / iOS 27 模拟器。截图由 UI 测试驱动真实 App，演示数据来自仅 DEBUG 可用的 `DemoData.swift`。

```bash
cd 02-development

# 1. 中文（主模拟器，系统语言为中文）
xcrun simctl uninstall booted com.hmh.nook   # 清空旧数据，确保种子重写
TEST_RUNNER_CAPTURE_APPSTORE=1 xcodebuild test \
  -project src/Nook.xcodeproj -scheme Nook \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5)' \
  -only-testing:NookUITests/AppStoreScreenshots \
  -resultBundlePath /tmp/nook-zh.xcresult

# 2. 英文（另建一台系统语言为 en 的同型号模拟器）
EN=$(xcrun simctl create "Nook Screenshots EN" \
  "com.apple.CoreSimulator.SimDeviceType.iPad-Pro-13-inch-M5-12GB" \
  "com.apple.CoreSimulator.SimRuntime.iOS-27-0")
xcrun simctl boot "$EN"
xcrun simctl spawn "$EN" defaults write .GlobalPreferences AppleLanguages -array en
xcrun simctl spawn "$EN" defaults write .GlobalPreferences AppleLocale -string en_US
xcrun simctl shutdown "$EN" && xcrun simctl boot "$EN"
TEST_RUNNER_CAPTURE_APPSTORE=1 TEST_RUNNER_CAPTURE_LANG=en xcodebuild test \
  -project src/Nook.xcodeproj -scheme Nook \
  -destination "platform=iOS Simulator,id=$EN" \
  -only-testing:NookUITests/AppStoreScreenshots \
  -resultBundlePath /tmp/nook-en.xcresult
```

导出与渲染：

```bash
# 3. 导出附件并重命名为 01–05.png
xcrun xcresulttool export attachments --path /tmp/nook-zh.xcresult --output-path /tmp/nook-zh-att

# 4. 归正方向（XCTest 截图是 2064×2752 + EXIF，必须转成真正的 2752×2064）
swift assets/appstore/tools/normalize.swift /tmp/nook-zh-att/01.png assets/appstore/screenshots-landscape/zh/01.png

# 5. 渲染成品
assets/appstore/tools/render.sh zh 1 assets/appstore/final/screenshots/zh-Hans/01.png
```

> 方向归正是必须步骤：`XCUIScreen.screenshot()` 在横屏下输出的是竖屏像素 + EXIF 旋转标记，直接上传 App Store 会得到错误方向。`normalize.swift` 会烘焙方向并去掉元数据。

## 上传到 App Store Connect

1. App 信息：名称 **知栈**，副标题 **高效学习资料分类管理**；英文区名称 **KnowStack**，副标题 **Organize study materials fast**。
2. 分类：教育（主要）/ 效率（次要）；年龄分级 4+；版权 `© 2026 知栈 · KnowStack`。
3. App 隐私：不收集数据；跟踪选否。
4. 版本信息：粘贴 `metadata/zh-Hans.md` 与 `metadata/en-US.md` 的描述、关键词、推广文本。
5. 截图：上传 `final/screenshots/zh-Hans/01–05.png`（2752×2064 横屏）与 `en-US/01–05.png`。
6. 构建：Xcode Archive → TestFlight → 版本页选择构建。
7. 审核备注：粘贴元数据中的 Review Notes。
8. 出口合规：建议在 Info.plist 加 `ITSAppUsesNonExemptEncryption = NO`。

## GitHub Pages

站点已通过 `gh-pages` 分支上线，已验证可访问：

- 首页：https://gheminghui.github.io/Nook/
- 支持页：https://gheminghui.github.io/Nook/support.html
- 隐私政策：https://gheminghui.github.io/Nook/privacy.html

元数据里的支持网址、隐私政策网址已替换为以上地址。

## 待确认

- [x] 支持网址、隐私政策网址（已上线）
- [x] 联系邮箱：minghuihe2022@163.com（已写入站点与元数据）
- [ ] 版权主体（当前写 `© 2026 知栈 · KnowStack`）
- [ ] 价格（当前按免费填写）

## 已知限制

- 图标 dark / tinted 两个变体与主图标相同；iOS 18 深色模式可用，但不够精致。
- 英文区截图的演示数据（文件名、文件夹、标签）仍是中文。
- 未制作 App 预览视频（可选）。
- 演示数据种子与截图 UI 测试仅 DEBUG 编译；普通测试会自动跳过截图用例。

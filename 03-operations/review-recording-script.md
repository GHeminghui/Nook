# App Review 录屏 · 照着做脚本

> 目标：一段 3–4 分钟的真机录屏，从点 App 图标开始，覆盖导入、文件夹、标签、搜索、PDF 标注、HTML 预览、分享扩展。
> 建议用 **English 系统语言** 录制（App 显示 KnowStack），审核员最容易看懂；括号里是中文界面的按钮名。

## 0. 录制前 10 分钟准备

- [ ] 用**物理 iPad**，系统升到最新 iPadOS；装 TestFlight 的 `1.0 (1)`
- [ ] 将 iPad 语言设为 **English**（设置 → 通用 → 语言与地区）
- [ ] 开「勿扰模式」，清空通知；设置 → 显示与亮度 → 自动锁定 → **永不**
- [ ] 横屏，亮度调高；关闭其他 App
- [ ] 在「文件」App → 我的 iPad 新建文件夹 **ReviewSamples**
- [ ] 下载 [samples.zip](https://gheminghui.github.io/Nook/review/samples.zip)，解压到 `ReviewSamples`
- [ ] 先在 Files 里试一次分享：长按 `sample-image.png` → 共享 → **Save to KnowStack**（存入知栈）；如果没看到，点「更多 / More」把它打开
- [ ] 删除旧版 App 后重装，保证资料库是空的（**不要带个人文件上镜**）
- [ ] 自己完整走一遍，确认不闪退、分享扩展可用

## 1. 开始录制

控制中心 → 屏幕录制 → 回到主屏幕 → 开始操作。

> 录屏要从**主屏幕点 App 图标**开始，不要从 App 内部开始。

## 2. 时间轴脚本

> 下面的时间点只是拍摄时的节奏参考，**不要直接写进 YouTube 描述**；除非你上传后核对过实际时间，否则描述里只写操作顺序即可。

### 0:00–0:08 启动

1. 主屏幕找到 **KnowStack（知栈）** 图标；
2. 点开，等待启动；
3. 画面出现「All Materials / 全部资料」空列表，停 2 秒。

### 0:08–0:40 建三级文件夹

1. 点左侧栏顶部的 **+**；
2. 选 **New Folder / 新建文件夹**；
3. 输入 `Math`，点 **Create / 创建**；
4. 再点 **+** → **New Folder**，输入 `Grade 10`，点 **Create**；
   - 弹窗里应显示 `Location: Math`（创建位置：Math）
5. 再点 **+** → **New Folder**，输入 `Functions`，点 **Create**；
   - 应显示 `Location: Math / Grade 10`
6. 左侧应看到 `Math > Grade 10 > Functions`，选中 `Functions`。

> 如果新文件夹没有自动选中，先点一下父文件夹再建下一级。

### 0:40–0:55 建两个标签

1. 点 **+** → **New Tag / 新建标签**；
2. 输入 `Key`，点 **Create / 创建**；
3. 再点 **+** → **New Tag**，输入 `Review`，点 **Create**；
4. 搜索框下方出现 `Key`、`Review` 两个标签胶囊。

> 必须先建标签再导入，导入后的批量打标签面板里才有选项。

### 0:55–1:25 导入三种文件

1. 点右上角 **Import / 导入**（下载箭头）；
2. 文件选择器如果停在「Recents / 最近使用」，点 **Browse / 浏览**；
3. 进入 **On My iPad / 我的 iPad → ReviewSamples**；
4. 点右上角 **Select / 选择**，依次点：
   - `sample-functions.pdf`
   - `sample-web-slide.html`
   - `sample-image.png`
5. 点 **Open / 打开**；
6. 弹出 **Add tags to 3 items / 给 3 份资料打标签**：
   - 点 `Key` 和 `Review`，出现勾选；
   - 点 **Done / 完成**；
7. 回到 `Functions` 文件夹，应看到 3 份资料。

> 如果没弹出打标签面板，说明标签没建成功；先跳过，后面长按资料补标签。

### 1:25–1:50 搜索与标签筛选

1. 点搜索框 **Search file names or content / 搜索文件名或正文**；
2. 输入 `functions`，停 2 秒，看到 PDF 被筛出来；
3. 点搜索框右侧 **×** 清空；
4. 点标签 **Key**，看到三份资料被筛出；
5. 再点一次 **Key** 取消筛选。

### 1:50–2:30 PDF 标注

1. 点 `sample-functions.pdf` 卡片；
2. 出现 **Opening… / 正在打开…** 浮层，等系统预览打开；
3. 点右上角 **标记 / Markup**（铅笔图标）；
4. 选笔，在 “Vertex” 或公式附近画一个圈/下划线；
5. 点 **Done / 完成** 退出标注；
6. 再点 **Done / 完成**（或左上角 ×）关闭预览，回到列表；
7. 可以再点开 PDF 一次，让审核员看到标注已保存。

> 没有 Apple Pencil 就用手指画；有 Pencil 更好。

### 2:30–2:55 HTML 预览

1. 点 `sample-web-slide.html`；
2. 展示渲染出的公式卡片页面，停 2 秒；
3. 点左上角返回；
4. （可选）点 `sample-image.png` 展示图片预览，再返回。

### 2:55–3:25 分享扩展

1. 回到主屏幕；
2. 从底部上滑并停住，把 KnowStack 卡片上滑**关闭 App**（重要：下次启动才会导入收件箱）；
3. 打开 **Files / 文件** → `ReviewSamples`；
4. 长按 `sample-image.png` → **Share / 共享**；
5. 在 App 行里点 **Save to KnowStack / 存入知栈**；
6. 录到扩展提示 **Saved to KnowStack / 已存入知栈**（约 0.6 秒）。

### 3:25–3:40 回到 App 验证

1. 回到主屏幕，点 **KnowStack** 启动；
2. 左侧栏出现 **Unsorted / 未分类** 文件夹；
3. 点进去，看到刚分享的图片；
4. 停 2 秒，结束录屏。

## 3. 录完检查

- [ ] 视频从主屏幕点图标开始
- [ ] 能看到 Math / Grade 10 / Functions 三级
- [ ] 能看到三种文件都导入成功
- [ ] 能看到标签、搜索、PDF 标注保存、HTML 渲染
- [ ] 能看到分享扩展的「Save to KnowStack」和「Unsorted」里的文件
- [ ] 没有出现真实姓名、通知、聊天内容
- [ ] 时长 3–4 分钟，画面不抖

## 4. 视频怎么给审核员

推荐 **不公开 YouTube / Vimeo**，或直接放 GitHub Pages：

- 把视频命名为 `demo.mp4`，放到 `assets/appstore/site/review/demo.mp4`；
- 推送到 `gh-pages` 后链接为：
  `https://gheminghui.github.io/Nook/review/demo.mp4`
- 单文件 < 100 MB，建议 720p。

把链接填进 `03-operations/app-review-response.md` 的 `[RECORDING URL]`，再粘贴到 App Review Notes。

## 5. 常见卡点

| 现象 | 处理 |
|---|---|
| 文件选择器找不到 ReviewSamples | 先在 Files 里确认文件夹在「我的 iPad」下；重新进 Browse |
| 不能多选 | 点右上角 Select；或逐个点文件让它们出现勾选 |
| 导入后没有打标签面板 | 标签没建；跳过，长按资料 → Edit Tags 补 |
| Share 里没有 Save to KnowStack | 分享面板 → More → 打开；或重启设备 |
| 分享后 App 里没出现 | 必须**彻底关闭 App 再启动**，收件箱只在启动时导入 |
| PDF 没有标记按钮 | 等预览加载完；点铅笔图标；确认不是只读预览 |

## 6. 相关

- App Review 补件说明：`03-operations/app-review-response.md`
- 示例文件：https://gheminghui.github.io/Nook/review/

#if DEBUG
import Foundation
import SwiftData
import SwiftUI
import UIKit

/// 仅用于生成 App Store 截图：用真实数据填充一个演示资料库。
/// 通过启动参数 `-nook-demo-seed` 触发，Release 构建不包含本文件内容。
@MainActor
enum DemoData {
    static var isSeedRequested: Bool {
        ProcessInfo.processInfo.arguments.contains("-nook-demo-seed")
    }

    /// 截图时隐藏「未登录 iCloud」状态行：它只反映模拟器环境，不代表产品能力。
    static var hidesSyncStatus: Bool {
        ProcessInfo.processInfo.arguments.contains("-nook-demo-hide-sync")
    }

    static func seedIfNeeded(store: LibraryStore) {
        guard isSeedRequested else { return }
        let context = store.context
        let existing = (try? context.fetchCount(FetchDescriptor<Item>())) ?? 0
        guard existing == 0 else { return }

        let temp = FileManager.default.temporaryDirectory
            .appendingPathComponent("NookDemo-\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: temp, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: temp) }

        // 文件夹
        let math = (try? store.createFolder(named: "数学", parent: nil))
        math?.sortOrder = 0
        let chinese = (try? store.createFolder(named: "语文", parent: nil))
        chinese?.sortOrder = 1
        let english = (try? store.createFolder(named: "英语", parent: nil))
        english?.sortOrder = 2
        let slides = (try? store.createFolder(named: "课件", parent: nil))
        slides?.sortOrder = 3
        let senior = math.flatMap { try? store.createFolder(named: "高一", parent: $0) }
        let functions = senior.flatMap { try? store.createFolder(named: "函数", parent: $0) }

        // 标签
        let key = try? store.createTag(named: "重点", colorHex: "#FF6B4A")
        let trap = try? store.createTag(named: "易错", colorHex: "#E5484D")
        let review = try? store.createTag(named: "复习", colorHex: "#4C5CAE")
        let lesson = try? store.createTag(named: "课堂", colorHex: "#2FA36B")

        var order = 0
        func add(_ url: URL, to folder: Folder?, tags: [Tag?]) {
            guard let item = try? store.importFile(at: url, into: folder) else { return }
            item.sortOrder = order
            order += 1
            for tag in tags.compactMap({ $0 }) {
                try? store.addTag(tag, to: item)
            }
        }

        // 函数文件夹
        let monotonic = temp.appendingPathComponent("函数的单调性.pdf")
        writeWorksheet(
            to: monotonic,
            kicker: "高一数学 · 必修一",
            title: "函数的单调性",
            intro: "设函数 f(x) 的定义域为 I。如果对于定义域 I 内某个区间 D 上的任意两个自变量 x₁、x₂，当 x₁ < x₂ 时，都有 f(x₁) < f(x₂)，那么就说 f(x) 在区间 D 上是增函数；反之则为减函数。",
            sections: [
                ("一、判定方法", [
                    "取值：在区间内任取 x₁、x₂，且 x₁ < x₂；",
                    "作差：计算 f(x₁) − f(x₂) 并变形；",
                    "定号：判断差的符号，得出结论。"
                ]),
                ("二、例题", [
                    "证明 f(x) = x² 在 [0, +∞) 上单调递增。",
                    "设 0 ≤ x₁ < x₂，则 f(x₁) − f(x₂) = (x₁ − x₂)(x₁ + x₂) < 0。"
                ])
            ]
        )
        add(monotonic, to: functions, tags: [key, review])

        let drill = temp.appendingPathComponent("函数专项练习.pdf")
        writeWorksheet(
            to: drill,
            kicker: "高一数学 · 课后练习",
            title: "函数专项练习",
            intro: "本练习覆盖定义域、值域、单调性与奇偶性四个考点。建议限时 40 分钟完成，做完后对照解析订正。",
            sections: [
                ("一、选择题", [
                    "1. 函数 f(x) = √(x − 1) 的定义域是（  ）",
                    "2. 下列函数中，在 (0, +∞) 上单调递减的是（  ）"
                ]),
                ("二、解答题", [
                    "3. 判断 f(x) = x + 1/x 在 [1, +∞) 上的单调性，并证明。",
                    "4. 已知 f(x) 是偶函数，且在 [0, +∞) 上递增，比较 f(−2) 与 f(3) 的大小。"
                ])
            ]
        )
        add(drill, to: functions, tags: [trap])

        let chart = temp.appendingPathComponent("二次函数图像.png")
        writeParabolaImage(to: chart)
        add(chart, to: functions, tags: [trap])

        let formulas = temp.appendingPathComponent("三角函数公式卡.html")
        writeFormulaCard(to: formulas)
        add(formulas, to: functions, tags: [key, lesson])

        // 数学 / 语文 / 英语 / 课件
        let midterm = temp.appendingPathComponent("期中试卷.pdf")
        writeWorksheet(
            to: midterm,
            kicker: "高一数学 · 2026 秋季",
            title: "期中综合试卷",
            intro: "满分 150 分，考试时间 120 分钟。请将答案写在答题卡上，保持卷面整洁。",
            sections: [
                ("一、填空题", ["1. 已知集合 A = {1, 2, 3}，B = {2, 3, 4}，则 A ∩ B = ______。"]),
                ("二、解答题", ["2. 解不等式 x² − 5x + 6 < 0。", "3. 求函数 y = 2sin(2x + π/6) 的最小正周期与最大值。"])
            ]
        )
        add(midterm, to: math, tags: [review])

        let classical = temp.appendingPathComponent("文言文实词整理.pdf")
        writeWorksheet(
            to: classical,
            kicker: "高一语文 · 文言文",
            title: "文言文实词整理",
            intro: "整理《劝学》《师说》两篇中的高频实词，按一词多义、古今异义、词类活用三类归纳。",
            sections: [
                ("一、一词多义", ["绝：假舟楫者，非能水也，而绝江河（横渡）", "强：蚓无爪牙之利，筋骨之强（强健）"]),
                ("二、词类活用", ["上：上食埃土（名词作状语，向上）", "水：非能水也（名词作动词，游泳）"])
            ]
        )
        add(classical, to: chinese, tags: [review])

        let essay = temp.appendingPathComponent("作文素材.html")
        writeEssayCard(to: essay)
        add(essay, to: chinese, tags: [lesson])

        let tenses = temp.appendingPathComponent("英语时态练习.pdf")
        writeWorksheet(
            to: tenses,
            kicker: "高一英语 · Grammar",
            title: "英语时态练习",
            intro: "Complete the sentences with the correct tense of the verbs in brackets.",
            sections: [
                ("Present Perfect", ["1. I ______ (finish) my homework already.", "2. She ______ (live) here since 2020."]),
                ("Past Simple", ["3. We ______ (visit) the museum last Friday.", "4. They ______ (not / come) to the party yesterday."])
            ]
        )
        add(tenses, to: english, tags: [lesson])

        let listening = temp.appendingPathComponent("听力原文.pdf")
        writeWorksheet(
            to: listening,
            kicker: "高一英语 · Listening",
            title: "听力原文与解析",
            intro: "Text 1  W: Excuse me, where is the nearest library?  M: Go straight and turn left at the second crossing.",
            sections: [("重点表达", ["go straight 直走", "turn left 左转", "at the second crossing 在第二个路口"])]
        )
        add(listening, to: english, tags: [lesson])

        let firstLesson = temp.appendingPathComponent("开学第一课.html")
        writeFirstLesson(to: firstLesson)
        add(firstLesson, to: slides, tags: [lesson])

        let mistakes = temp.appendingPathComponent("错题本.pdf")
        writeWorksheet(
            to: mistakes,
            kicker: "高一数学 · 错题整理",
            title: "九月错题本",
            intro: "把每次作业和测验中的错题按知识点归档，每周复盘一次，重点标注反复出错的原因。",
            sections: [
                ("一、函数定义域", ["忽略分母不为零，导致定义域漏解。", "根号内表达式需满足非负。"]),
                ("二、二次函数", ["配方时符号出错，顶点坐标写成 (−2, 1)。", "对称轴与区间端点混淆。"])
            ]
        )
        add(mistakes, to: math, tags: [review])

        let unitTest = temp.appendingPathComponent("单元测试.pdf")
        writeWorksheet(
            to: unitTest,
            kicker: "高一数学 · 单元检测",
            title: "函数单元测试",
            intro: "本卷共 20 题，满分 100 分，建议用时 45 分钟。请独立完成后再对照答案。",
            sections: [
                ("一、基础题", ["1. 求函数 f(x) = 1/(x − 2) 的定义域。", "2. 判断 f(x) = x³ 的奇偶性。"]),
                ("二、提高题", ["3. 已知 f(x + 1) = x² + 2x，求 f(x)。"])
            ]
        )
        add(unitTest, to: math, tags: [trap])

        let poetry = temp.appendingPathComponent("古诗文默写.pdf")
        writeWorksheet(
            to: poetry,
            kicker: "高一语文 · 默写",
            title: "古诗文默写清单",
            intro: "默写篇目：《劝学》《师说》《赤壁赋》。注意易错字：跬、锲、镂、跬步。",
            sections: [
                ("一、劝学", ["故不积跬步，无以至千里；不积小流，无以成江海。"]),
                ("二、师说", ["是故弟子不必不如师，师不必贤于弟子。"])
            ]
        )
        add(poetry, to: chinese, tags: [key])

        let reading = temp.appendingPathComponent("阅读答题模板.html")
        writeSimpleHTML(
            to: reading,
            title: "现代文阅读 · 答题模板",
            kicker: "高一语文 · 阅读",
            body: """
            <h2>一、概括题</h2>
            <p>格式：谁 + 在什么情况下 + 做了什么 + 结果如何。先分层，再合并，避免照抄原文。</p>
            <h2>二、赏析题</h2>
            <p>手法 + 内容 + 情感 + 效果。答题时先点明手法，再结合句子分析，最后落到情感。</p>
            """
        )
        add(reading, to: chinese, tags: [lesson])

        let grammar = temp.appendingPathComponent("语法笔记.pdf")
        writeWorksheet(
            to: grammar,
            kicker: "高一英语 · Grammar Notes",
            title: "时态与语态笔记",
            intro: "一般现在时表示习惯与客观事实；现在完成时强调过去动作对现在的影响。",
            sections: [
                ("Key Points", ["since + 时间点，for + 时间段。", "被动语态：be + 过去分词。"]),
                ("Examples", ["She has taught here for five years.", "The classroom is cleaned every day."])
            ]
        )
        add(grammar, to: english, tags: [key])

        let words = temp.appendingPathComponent("单词表.pdf")
        writeWorksheet(
            to: words,
            kicker: "高一英语 · Unit 1",
            title: "核心单词表",
            intro: "本单元共 42 个核心词，按词性分组，建议每天滚动复习 10 个。",
            sections: [
                ("Verbs", ["achieve v. 实现，达到", "improve v. 改进，提高", "prefer v. 更喜欢"]),
                ("Nouns", ["attitude n. 态度", "challenge n. 挑战", "progress n. 进步"])
            ]
        )
        add(words, to: english, tags: [review])

        let parents = temp.appendingPathComponent("家长会.html")
        writeSimpleHTML(
            to: parents,
            title: "家长会 · 学情反馈",
            kicker: "本学期 · 期中",
            body: """
            <h2>班级整体情况</h2>
            <p>本月作业完成率 96%，课堂发言人次较上月提升 18%。</p>
            <h2>需要家长配合</h2>
            <p>每天固定 30 分钟阅读时间；周末一起整理一次错题本。</p>
            """
        )
        add(parents, to: slides, tags: [lesson])

        let range = temp.appendingPathComponent("函数的值域.pdf")
        writeWorksheet(
            to: range,
            kicker: "高一数学 · 函数",
            title: "函数的值域求法",
            intro: "常见方法：观察法、配方法、换元法、单调性法、判别式法。先看定义域，再选方法。",
            sections: [
                ("一、配方法", ["y = x² − 2x + 3 = (x − 1)² + 2，故值域为 [2, +∞)。"]),
                ("二、换元法", ["含根号的函数先换元，注意新变量的取值范围。"])
            ]
        )
        add(range, to: functions, tags: [key])

        let exponential = temp.appendingPathComponent("指数函数.pdf")
        writeWorksheet(
            to: exponential,
            kicker: "高一数学 · 必修一",
            title: "指数函数及其性质",
            intro: "y = aˣ（a > 0 且 a ≠ 1）。当 a > 1 时单调递增，当 0 < a < 1 时单调递减，图象恒过 (0, 1)。",
            sections: [
                ("一、图象", ["底数越大，第一象限图象越靠近 y 轴。"]),
                ("二、比较大小", ["同底看单调性，不同底找中间量 1。"])
            ]
        )
        add(exponential, to: functions, tags: [lesson])

        let logarithm = temp.appendingPathComponent("对数运算.pdf")
        writeWorksheet(
            to: logarithm,
            kicker: "高一数学 · 必修一",
            title: "对数运算易错点",
            intro: "loga(MN) = logaM + logaN，注意真数必须大于零，底数大于零且不等于 1。",
            sections: [
                ("常见错误", ["把 loga(M + N) 拆成 logaM + logaN。", "忽略真数取值范围导致增根。"]),
                ("练习", ["计算 log₂8 + log₃(1/9)。"])
            ]
        )
        add(logarithm, to: functions, tags: [trap])

        let sets = temp.appendingPathComponent("集合与不等式.pdf")
        writeWorksheet(
            to: sets,
            kicker: "高一数学 · 第一章",
            title: "集合与不等式",
            intro: "集合的运算包括交、并、补；解不等式时注意临界点与区间开闭。",
            sections: [
                ("一、集合", ["A ∩ B = {x | x ∈ A 且 x ∈ B}。"]),
                ("二、不等式", ["x² − 5x + 6 < 0 的解集为 (2, 3)。"])
            ]
        )
        add(sets, to: math, tags: [key])

        let geometry = temp.appendingPathComponent("立体几何.pdf")
        writeWorksheet(
            to: geometry,
            kicker: "高一数学 · 必修二",
            title: "立体几何初步",
            intro: "空间几何体、点线面位置关系、平行与垂直的判定。作图时注意虚实线。",
            sections: [
                ("一、判定定理", ["线面平行：平面外一条直线与此平面内一条直线平行。"]),
                ("二、性质定理", ["线面平行：过这条直线的平面与此平面相交，交线与该直线平行。"])
            ]
        )
        add(geometry, to: math, tags: [review])

        let idioms = temp.appendingPathComponent("成语积累.pdf")
        writeWorksheet(
            to: idioms,
            kicker: "高一语文 · 积累",
            title: "易错成语 30 例",
            intro: "按望文生义、对象误用、褒贬误用三类整理，每天记 5 个。",
            sections: [
                ("望文生义", ["差强人意：大体上还能使人满意，不是“不满意”。"]),
                ("对象误用", ["汗牛充栋：形容书籍多，不能形容人。"])
            ]
        )
        add(idioms, to: chinese, tags: [trap])

        let readingEnglish = temp.appendingPathComponent("阅读理解.pdf")
        writeWorksheet(
            to: readingEnglish,
            kicker: "高一英语 · Reading",
            title: "阅读理解 · 主旨题技巧",
            intro: "主旨题优先看首段、尾段和每段首句；选项过于具体或过于宽泛都要排除。",
            sections: [
                ("Step 1", ["Skim the first and last paragraphs."]),
                ("Step 2", ["Match the main idea, not a single detail."])
            ]
        )
        add(readingEnglish, to: english, tags: [key])

        let trigSlides = temp.appendingPathComponent("三角函数课件.html")
        writeSimpleHTML(
            to: trigSlides,
            title: "三角函数 · 课堂课件",
            kicker: "高一数学 · 必修一",
            body: """
            <h2>一、任意角与弧度制</h2>
            <p>1 弧度 = 180/π 度；弧长 l = |α|r，扇形面积 S = ½|α|r²。</p>
            <h2>二、诱导公式</h2>
            <p>奇变偶不变，符号看象限。先把角化到 0°~360°，再用公式化简。</p>
            <h2>三、课堂练习</h2>
            <p>求 sin 150°、cos(−60°)、tan 225° 的值。</p>
            """
        )
        add(trigSlides, to: slides, tags: [lesson])

        try? context.save()
    }

    static func applyRequestedScreen(
        store: LibraryStore,
        criteria: Binding<SearchService.Criteria>,
        selection: Binding<Folder?>
    ) {
        if let name = value(after: "-nook-demo-folder") {
            let descriptor = FetchDescriptor<Folder>(predicate: #Predicate { $0.name == name })
            if let folder = try? store.context.fetch(descriptor).first {
                selection.wrappedValue = folder
            }
        }

        if let text = value(after: "-nook-demo-search") {
            criteria.wrappedValue.text = text
        }

        if let name = value(after: "-nook-demo-tag") {
            let descriptor = FetchDescriptor<Tag>(predicate: #Predicate { $0.name == name })
            if let tag = try? store.context.fetch(descriptor).first {
                criteria.wrappedValue.tagIDs.insert(tag.id)
            }
        }
    }

    private static func value(after flag: String) -> String? {
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: flag), args.index(after: index) < args.endIndex else {
            return nil
        }
        return args[args.index(after: index)]
    }

    // MARK: - 生成示例文件

    private static let indigo = UIColor(red: 0.298, green: 0.361, blue: 0.682, alpha: 1)
    private static let coral = UIColor(red: 1.0, green: 0.42, blue: 0.29, alpha: 1)
    private static let ink = UIColor(red: 0.12, green: 0.13, blue: 0.16, alpha: 1)
    private static let muted = UIColor(red: 0.37, green: 0.39, blue: 0.44, alpha: 1)

    private static func writeWorksheet(
        to url: URL,
        kicker: String,
        title: String,
        intro: String,
        sections: [(String, [String])]
    ) {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: 842))
        try? renderer.writePDF(to: url) { context in
            context.beginPage()
            drawPaperHeader(kicker: kicker, title: title)

            var y: CGFloat = 164
            drawParagraph(intro, at: CGRect(x: 48, y: y, width: 499, height: 120), font: .systemFont(ofSize: 13))
            y += 132

            for (heading, lines) in sections {
                draw(heading, in: CGRect(x: 48, y: y, width: 499, height: 26), font: .systemFont(ofSize: 16, weight: .semibold))
                y += 32
                for line in lines {
                    drawParagraph("· " + line, at: CGRect(x: 48, y: y, width: 499, height: 60), font: .systemFont(ofSize: 13))
                    y += 34
                }
                y += 16
            }

            draw("知栈 · 学习资料库", in: CGRect(x: 48, y: 790, width: 300, height: 20), font: .systemFont(ofSize: 9), color: muted)
        }
    }

    private static func drawPaperHeader(kicker: String, title: String) {
        UIColor.white.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 595, height: 842))
        indigo.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 595, height: 8))
        draw(kicker, in: CGRect(x: 48, y: 46, width: 499, height: 22), font: .systemFont(ofSize: 12, weight: .medium), color: muted)
        draw(title, in: CGRect(x: 48, y: 72, width: 499, height: 46), font: .systemFont(ofSize: 28, weight: .bold))
        coral.setFill()
        UIRectFill(CGRect(x: 48, y: 126, width: 54, height: 4))
    }

    private static func draw(
        _ text: String,
        in rect: CGRect,
        font: UIFont,
        color: UIColor = .black,
        alignment: NSTextAlignment = .left
    ) {
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        style.lineSpacing = 7
        (text as NSString).draw(
            with: rect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font, .foregroundColor: color, .paragraphStyle: style],
            context: nil
        )
    }

    private static func drawParagraph(_ text: String, at rect: CGRect, font: UIFont) {
        draw(text, in: rect, font: font, color: ink)
    }

    private static func writeParabolaImage(to url: URL) {
        let size = CGSize(width: 1200, height: 900)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor(red: 0.996, green: 0.988, blue: 0.973, alpha: 1).setFill()
            context.fill(CGRect(origin: .zero, size: size))

            let plot = CGRect(x: 120, y: 140, width: 960, height: 640)
            let grid = UIColor(red: 0.85, green: 0.83, blue: 0.78, alpha: 1)
            grid.setStroke()
            for i in 0...8 {
                let x = plot.minX + plot.width * CGFloat(i) / 8
                let path = UIBezierPath()
                path.move(to: CGPoint(x: x, y: plot.minY))
                path.addLine(to: CGPoint(x: x, y: plot.maxY))
                path.lineWidth = 1
                path.stroke()
            }
            for i in 0...6 {
                let y = plot.minY + plot.height * CGFloat(i) / 6
                let path = UIBezierPath()
                path.move(to: CGPoint(x: plot.minX, y: y))
                path.addLine(to: CGPoint(x: plot.maxX, y: y))
                path.lineWidth = 1
                path.stroke()
            }

            // 坐标轴
            let axisColor = UIColor(red: 0.35, green: 0.37, blue: 0.42, alpha: 1)
            axisColor.setStroke()
            let axis = UIBezierPath()
            axis.move(to: CGPoint(x: plot.minX, y: plot.maxY - 120))
            axis.addLine(to: CGPoint(x: plot.maxX, y: plot.maxY - 120))
            axis.move(to: CGPoint(x: plot.minX + 240, y: plot.maxY))
            axis.addLine(to: CGPoint(x: plot.minX + 240, y: plot.minY))
            axis.lineWidth = 2
            axis.stroke()

            // y = x² − 4x + 3，x ∈ [-1, 5]
            let transform: (CGFloat) -> CGPoint = { x in
                let y = x * x - 4 * x + 3
                let px = plot.minX + 240 + x * 120
                let py = plot.maxY - 120 - y * 90
                return CGPoint(x: px, y: py)
            }
            let curve = UIBezierPath()
            var x: CGFloat = -1
            curve.move(to: transform(x))
            while x <= 5 {
                curve.addLine(to: transform(x))
                x += 0.04
            }
            curve.lineWidth = 5
            curve.lineJoinStyle = .round
            UIColor(red: 0.298, green: 0.361, blue: 0.682, alpha: 1).setStroke()
            curve.stroke()

            // 顶点
            let vertex = transform(2)
            UIColor(red: 1.0, green: 0.42, blue: 0.29, alpha: 1).setFill()
            UIBezierPath(ovalIn: CGRect(x: vertex.x - 9, y: vertex.y - 9, width: 18, height: 18)).fill()

            draw("二次函数 y = x² − 4x + 3", in: CGRect(x: 120, y: 48, width: 700, height: 60), font: .systemFont(ofSize: 34, weight: .bold), color: ink)
            draw("顶点 (2, −1) · 零点 x = 1, 3 · 对称轴 x = 2", in: CGRect(x: 120, y: 88, width: 900, height: 40), font: .systemFont(ofSize: 19), color: muted)
            draw("顶点", in: CGRect(x: vertex.x + 16, y: vertex.y - 10, width: 120, height: 30), font: .systemFont(ofSize: 18, weight: .semibold), color: coral)
        }
        try? image.pngData()?.write(to: url)
    }

    private static func writeSimpleHTML(to url: URL, title: String, kicker: String, body: String) {
        let html = """
        <!DOCTYPE html>
        <html lang="zh-CN">
        <head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><style>
          :root{--ink:#1d1f27;--muted:#5f6270;--indigo:#4c5cae;--coral:#ff6b4a}
          body{margin:0;padding:56px;background:#fcfaf5;color:var(--ink);font-family:-apple-system,"PingFang SC",sans-serif}
          .kicker{color:var(--muted);font-size:13px;letter-spacing:2px}
          h1{font-size:32px;margin:8px 0 10px}
          .rule{width:54px;height:4px;background:var(--coral);border-radius:2px;margin:12px 0 28px}
          h2{font-size:17px;color:var(--indigo);margin:26px 0 8px}
          p{font-size:16px;line-height:2;color:#2b2e36;margin:0}
        </style></head>
        <body><div class="kicker">\(kicker)</div><h1>\(title)</h1><div class="rule"></div>\(body)</body></html>
        """
        try? html.write(to: url, atomically: true, encoding: .utf8)
    }

    private static func writeFormulaCard(to url: URL) {
        let html = """
        <!DOCTYPE html>
        <html lang="zh-CN">
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          :root { --ink:#1d1f27; --muted:#5f6270; --indigo:#4c5cae; --coral:#ff6b4a; --paper:#fcfaf5; }
          * { box-sizing: border-box; }
          body { margin:0; padding:48px 56px 64px; background:var(--paper); color:var(--ink);
                 font-family:-apple-system,"PingFang SC","Helvetica Neue",sans-serif; }
          .kicker { color:var(--muted); font-size:13px; letter-spacing:2px; }
          h1 { font-size:34px; margin:8px 0 6px; letter-spacing:-1px; }
          .rule { width:54px; height:4px; background:var(--coral); border-radius:2px; margin:14px 0 30px; }
          .grid { display:grid; grid-template-columns:1fr 1fr; gap:18px; }
          .card { background:#fff; border:1px solid #e7e1d4; border-radius:16px; padding:22px 24px; }
          .card h2 { font-size:15px; color:var(--indigo); margin:0 0 10px; letter-spacing:1px; }
          .formula { font-family:"Times New Roman",serif; font-size:24px; line-height:1.5; }
          .note { color:var(--muted); font-size:13px; margin-top:10px; line-height:1.7; }
          footer { margin-top:30px; color:var(--muted); font-size:12px; }
        </style>
        </head>
        <body>
          <div class="kicker">高一数学 · 必修一</div>
          <h1>三角函数 · 公式卡</h1>
          <div class="rule"></div>
          <div class="grid">
            <div class="card">
              <h2>同角关系</h2>
              <div class="formula">sin²α + cos²α = 1</div>
              <div class="note">由单位圆定义直接得到，是化简与证明的基础。</div>
            </div>
            <div class="card">
              <h2>和角公式</h2>
              <div class="formula">sin(α±β) = sinαcosβ ± cosαsinβ</div>
              <div class="note">注意符号与函数名的对应关系。</div>
            </div>
            <div class="card">
              <h2>二倍角</h2>
              <div class="formula">sin2α = 2sinαcosα</div>
              <div class="note">降幂与升幂公式都由它变形而来。</div>
            </div>
            <div class="card">
              <h2>辅助角</h2>
              <div class="formula">a sinx + b cosx = √(a²+b²)·sin(x+φ)</div>
              <div class="note">其中 tanφ = b/a，常用于求最值。</div>
            </div>
          </div>
          <footer>知栈 · 学习资料库</footer>
        </body>
        </html>
        """
        try? html.write(to: url, atomically: true, encoding: .utf8)
    }

    private static func writeEssayCard(to url: URL) {
        let html = """
        <!DOCTYPE html>
        <html lang="zh-CN">
        <head><meta charset="utf-8"><style>
          body{margin:0;padding:56px;background:#fcfaf5;color:#1d1f27;font-family:-apple-system,"PingFang SC",sans-serif}
          h1{font-size:32px;margin:0 0 6px} .sub{color:#5f6270;font-size:15px;margin-bottom:26px}
          h2{font-size:16px;color:#4c5cae;margin:26px 0 8px}
          p{font-size:15px;line-height:1.9;color:#2b2e36;margin:0 0 8px}
          blockquote{margin:16px 0;padding:14px 18px;border-left:4px solid #ff6b4a;background:#fff;color:#3a3d45}
        </style></head>
        <body>
          <h1>作文素材 · 人物与细节</h1>
          <div class="sub">高一语文 · 记叙文写作</div>
          <h2>一、关于“坚持”</h2>
          <blockquote>真正的坚持，不是从不疲惫，而是疲惫时仍愿意再走一步。</blockquote>
          <p>可结合袁隆平、张桂梅等人物事例，注意写出具体动作与场景，避免空泛议论。</p>
          <h2>二、细节描写</h2>
          <p>写人时少用形容词，多写手上的动作、衣角的磨损、说话前的停顿。</p>
        </body></html>
        """
        try? html.write(to: url, atomically: true, encoding: .utf8)
    }

    private static func writeFirstLesson(to url: URL) {
        let html = """
        <!DOCTYPE html>
        <html lang="zh-CN">
        <head><meta charset="utf-8"><style>
          body{margin:0;padding:56px;background:#fcfaf5;color:#1d1f27;font-family:-apple-system,"PingFang SC",sans-serif}
          .kicker{color:#5f6270;font-size:13px;letter-spacing:2px}
          h1{font-size:36px;margin:8px 0 10px}
          .rule{width:54px;height:4px;background:#ff6b4a;border-radius:2px;margin:12px 0 28px}
          ol{font-size:16px;line-height:2.1;padding-left:22px}
          .tip{margin-top:28px;padding:16px 18px;background:#fff;border:1px solid #e7e1d4;border-radius:14px;color:#5f6270;font-size:14px}
        </style></head>
        <body>
          <div class="kicker">新学期 · 第一课</div>
          <h1>开学第一课</h1>
          <div class="rule"></div>
          <ol>
            <li>认识本学期的学习目标与评价方式</li>
            <li>建立资料归档习惯：每节课后 5 分钟整理</li>
            <li>确定小组分工与课堂约定</li>
            <li>布置第一次阅读任务</li>
          </ol>
          <div class="tip">建议：把课件、试卷、错题分别归档到「课件 / 试卷 / 错题」三个文件夹。</div>
        </body></html>
        """
        try? html.write(to: url, atomically: true, encoding: .utf8)
    }
}
#endif

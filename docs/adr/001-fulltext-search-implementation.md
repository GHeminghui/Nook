# ADR-001: v1 全文检索的实现方式

- **状态**：已采纳
- **日期**：2026-09-27
- **决策者**：项目组

## 背景

`01-design/tech-design.md` 在检索设计中提出使用 **SQLite FTS5** 建立全文索引。进入开发阶段编写实施计划时，需要确定 v1 具体落地方式。

约束：仅 iPad、免费、本地为主；开发环境为 Xcode 27 / Swift 6.4 / iOS SDK 27；需要**可被自动化测试真实验证**；v1 资料规模预期为千级以内。

## 决策

v1 采用「**SwiftData 文本字段（`Item.textContent`）+ 谓词/内存过滤**」实现全文检索，暂不引入 SQLite FTS5：

- 导入时用 `TextExtractor` 抽取 PDF/HTML 正文写入 `Item.textContent`；
- 检索由 `SearchService.search` 取候选后，用纯函数 `SearchService.matches` 按「文本 + 文件夹范围 + 标签」过滤。

## 备选方案

| 方案 | 优点 | 缺点 |
|------|------|------|
| A. SwiftData 文本字段 + 内存过滤（**采纳**） | 无 C 互操作；纯 Swift 易单测；实现简单；与 SwiftData 模型天然一致 | 数据量很大时全量扫描会变慢 |
| B. SQLite FTS5（原设计） | 大库检索快、支持复杂分词 | 需 SQLite3 C API 封装；索引与模型需双写同步；实现与测试成本高 |
| C. CoreSpotlight | 系统级索引、可被 Spotlight 搜到 | 索引写入受系统调度影响，测试确定性差；对"标签+范围"组合过滤不直接支持 |

## 后果

- **正面影响**：显著降低实现与测试成本；核心过滤逻辑成为可完整单测的纯函数，满足"测试须真实运行"的要求；与 SwiftData 模型单一数据源，无需维护第二套索引。
- **负面影响**：资料规模增长到万级以上时，检索响应可能下降；届时需迁移到 FTS5（方案 B）。
- **缓解**：`SearchService` 与 `IndexingPipeline` 已将"抽取/过滤"抽象为独立单元，未来替换为 FTS5 时改动面可控。
- **后续动作**：当单库资料量超过约 5000 条或检索耗时超过 1 秒时，新开一轮评估是否引入 FTS5。

## 相关链接

- [tech-design.md](../../01-design/tech-design.md)（检索设计，FTS5 方案）
- [plan.md](../../02-development/plan.md)（"与设计文档的偏差"）
- [SearchService.swift](../../02-development/src/Nook/Services/SearchService.swift)

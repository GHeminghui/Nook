# ADR-002：SwiftData 关闭 CloudKit，iCloud 同步仅用 iCloud Documents

- 日期：2026-10-18
- 状态：已采纳

## 背景

Nook 需要 iCloud 备份与多设备同步。设计阶段的方案是「文件放 iCloud 容器 + 元数据本地存储」，但工程启用 iCloud entitlement 后，SwiftData 的 `ModelConfiguration` 默认按 CloudKit 模式校验模型，要求所有关系都有 inverse、所有关系可选、所有属性有默认值，导致 `ModelContainer` 创建失败。

## 决策

- SwiftData 显式使用 `cloudKitDatabase: .none`。
- 文件（含资料本身）存放在 iCloud Documents 的 `Documents/Library`；未登录 iCloud 时回退到本地 `Documents/Library`。
- 元数据继续使用本地 SwiftData 存储，不接入 CloudKit 记录同步。

## 备选方案

1. 让全部模型满足 CloudKit 约束（关系可选、属性默认值），启用 SwiftData + CloudKit 同步。
2. 文件走 iCloud Documents，元数据单独接 CloudKit 私有库。
3. 不启用 iCloud，仅本地存储。

## 后果

- 优点：数据模型保持简洁；改动最小；离线可用；符合「本地为主 + 云备份」定位。
- 代价：元数据不随 CloudKit 做记录级同步；多设备并发修改为后写覆盖；需要用户登录 iCloud 才能跨设备看到文件。
- 后续如需记录级同步，可按备选方案 1 或 2 重新评估模型约束与迁移策略。

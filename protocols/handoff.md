# Olympus Protocol — Handoff

任务交接格式. zeus / lane owner / specialist 之间通过 handoff 协调.

## Handoff 文件命名

`.kiro/handoffs/H-YYYY-MM-DD-NNN-<slug>.md`

- `YYYY-MM-DD`: 日期 (创建日)
- `NNN`: 当日序号 (001 起递增)
- `<slug>`: 短标题 kebab-case

## Frontmatter (必填)

```yaml
---
id: H-YYYY-MM-DD-NNN
title: <一句话任务标题>
severity: P0 | P1 | P2 | P3
status: open | claimed | in_progress | done | verified | cancelled
reporter: zeus
assigned_to: <persona>
from: zeus
to: <persona>
lane: <lane>
touches:
  - <files / dirs glob>
related:
  - H-YYYY-MM-DD-NNN
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

## Body 结构

```markdown
# <Title>

## 一句话
<problem statement, 业务语言>

## 必加载 skill
| Skill / Agent | 何时用 |
|---|---|
| `.kiro/skills/<skill>/SKILL.md` | <场景> |

## 具体交付
- File 1
- File 2

**验收**: <可机械验证条件>

## 你自决 (灵活度)
- <choice 1>

## 边界 (不动)
- <other lane scope>

## 节奏 + 验收
- AI 速度推, 每 deliverable 独立 commit, message 加 [H-YYYY-MM-DD-NNN] 前缀
- 完成 status: open → done + EOD report push 到 body
- zeus 派 themis review → 通过 flip verified

— from @zeus
```

## Status 生命周期

```
open → claimed → in_progress → done → verified
                                      ↓
                                  (themis review 通过)
```

- `cancelled`: 任务终止 (不再做)
- 跳级 OK (open → in_progress 不必先 claimed)

## Forward (跨 session 转发)

bao 是异步通讯 messenger. zeus push handoff → bao copy forward block 到 lane owner session → lane owner pull 看到接活.

forward block 模板:
```
@<persona>: <一句话任务>.

git fetch origin && git pull
读 .kiro/handoffs/H-YYYY-MM-DD-NNN-<slug>.md

简版: <3-4 行核心要点>

— from @zeus
```

## Collision (跨 lane 撞)

某 lane owner 任务跨进另 lane scope:
- ✅ 开 mini-handoff (`from: <self>, to: <target lane owner>`) 派对方做
- ❌ 不直接 Edit 别人 lane 文件
- ❌ 不直接 push 别人 branch

## Handover (退役 / 交接)

persona 退役 / 交班:
- 写 `H-handover-<from>-to-<to>.md` 列已 ship + in-flight + 下个交接物
- status: open, assigned_to: <new persona>
- bao forward → 新 persona 接

## 反模式

- ❌ handoff 含 "do A then B then C..." 步骤序列 — 改用 acceptance criteria, 给 owner 自决路径
- ❌ handoff 嵌大段代码 — code 在 spec / source, handoff 引用即可
- ❌ 多 owner (`assigned_to` 多人) — 一个 handoff 一个 owner. 多人协作开 mini-handoff

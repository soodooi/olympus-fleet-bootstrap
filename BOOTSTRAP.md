# Olympus Fleet Bootstrap — 通用项目环境配置

> **给另一个 Claude 看**: 你现在要把 Olympus 多 agent fleet 系统装进一个新项目. 按以下步骤执行. 不是 mamamiya 特定, 任何项目都能用.

---

## 0. 前置条件

确保 host 机有:
- **Claude Code** v2.1.59+ (含 auto memory)
- **gh** (GitHub CLI) 登录
- **git** 配置 user.name + user.email
- **Python 3.12+** (claude-memory-compiler 用)
- **Node 20+** + **npm**
- 项目 git 仓库已初始化, 第一次 commit 已 push origin

如缺任一, 告诉用户先装再回来.

---

## 1. 项目类型识别 (第一步必做)

问用户 4 个问题, 决定 lane 分配策略:

1. **项目业务类型** (e.g., e-commerce / SaaS / 内部工具 / 数据平台 / 开源库)
2. **栈** (e.g., Next.js + Postgres / Vue + Cloudflare Workers / Django / 等)
3. **预期前端 surface 数量** (1 个站? 多 app? 移动 PWA?)
4. **预期 fleet 大小** (单人项目? 2-3 人? 5+ 人?)

根据答案决定:
- lane 分配 (frontend / backend / data / ops / 多少个)
- persona 数量 (核心 5 人最少 / 14 人完整版)
- 是否需要某些专门 lane (marketing? mobile? extension?)

---

## 2. 创建 .kiro 骨架

```bash
mkdir -p .kiro/{steering,steering/protocol,specs,handoffs,best-practice,skills,audits/auto-validate}
```

写 `.kiro/README.md`:
```markdown
# .kiro — 项目知识库

- `steering/` — 权威决策 + Olympus fleet 协议
- `specs/` — 功能 spec (4 步流程过 architecture check + review + e2e + data 才派遣)
- `handoffs/` — 跨 lane 任务交接 (H-YYYY-MM-DD-NNN 命名)
- `best-practice/` — 踩坑经验, KM (knowledge management) 沉淀
- `skills/` — 项目专属 skill (跟 ~/.claude/skills/ 区分)
- `audits/` — auto-validate 报告 + dike audit
```

---

## 3. Olympus Fleet 14 位花名册 (通用版)

写 `.kiro/steering/olympus-roster.md`:

```yaml
---
type: roster
version: v1.0
fleet_size: 14
created: <today>
---

# Olympus Fleet 花名册

## 角色 = persona (希腊神 + 业务定位 + 是否 lane owner)

### 核心 11 lane owner

| Persona | 神格 | 业务定位 (通用化) | Lane |
|---|---|---|---|
| **@zeus** | 主神 | 主 orchestrator, PM/CTO, **不写代码** | main tree, 协调 |
| **@atlas** | 扛天泰坦 | platform / cross-cutting 底座 owner | packages/platform/ + 共享层 |
| **@athena** | 智慧 | **主前端 surface 1** (核心管理后台) | apps/admin/ 或同类 |
| **@daedalus** | 工匠 | **主前端 surface 2** (创作 / 主用户面) | apps/creator-hub/ 或同类 |
| **@iris** | 信使 | VI / 设计语言制定 (跨 surface 标准) | packages/brand/ + design tokens |
| **@apollo** | 光明 | **市场 / 增长 / 公开传播** (如有) | marketing / growth lane |
| **@artemis** | 月神 | **数据 / 推荐 / 个性化** | recommendation / analytics |
| **@argus** | 百眼巨人 | **运维 / 监控 / 基础设施** (VPS / 部署) | infra / ops |
| **@hephaestus** | 锻造 | cross-lane execution arm (备用, 跨多 lane 时启用) | hephaestus (overflow) |
| **@metis** | 智慧泰坦 | **审计 / 回归测试 / 跨 cutting QA** | metis (audit) |
| **@dike** | 正义女神 | zeus 自身**质量自审** (启动期 daily, 成熟期 weekly) | zeus inline |

### 3 specialist (zeus inline 派遣)

| Persona | 神格 | 何时调 |
|---|---|---|
| **@themis** | 法律 | review chief of staff (PR review 派 ECC reviewer) |
| **@prometheus** | 智慧 | 后端 / 架构技术专家 (zeus inline review backend / arch design) |
| **@demeter** | 大地 | 数据 / DB / schema 专家 (zeus inline review schema decisions) |

> **小项目 (< 5 人)**: 留 zeus + atlas + 1-2 lane owner + dike + themis. 其他空着, 启动后渐增.

> **大项目 (5+ lane)**: 全 14 位.
```

---

## 4. Olympus 6 类协议法典

写 `.kiro/steering/olympus-protocol.md`:

```markdown
---
type: protocol-index
version: v1.0
---

# Olympus 协议法典 (6 子协议)

zeus 治理依据, 任何成员违反 = dike audit P0 flag.

| # | 子协议 | 路径 | 内容 |
|---|---|---|---|
| 1 | handoff | `protocol/handoff.md` | 任务交接格式 + signature + 跨 lane / 跨机器 / forward / collision / handover |
| 2 | review | `protocol/review.md` | tier (ABC) + specialist 决策树 + fix-commit grep + scope 升级 |
| 3 | git | `protocol/git.md` | commit / branch / squash-verify / pre-push / worktree / lane-guard 6 步 |
| 4 | conduct | `protocol/conduct.md` | 处女座 / 不绕 / 收尾 sequence / 离线处理 / 自决 |
| 5 | knowledge | `protocol/knowledge.md` | KM 三层 + 4 目标 + daily iteration workflow |
| 6 | verification | `protocol/verification.md` | spec pre-dispatch 4 步流程 (architect / review / e2e / data) |
```

每个子协议写一份 markdown, 控制 < 200 行. 内容详 [§7 协议详细].

---

## 5. Lane Ownership (通用化模板)

写 `.kiro/steering/lane-ownership.yaml`:

```yaml
---
version: v1.0
created: <today>
---

# 通用 Lane 边界 (按你项目实际改)

lanes:
  platform:
    owner: atlas
    files:
      - packages/platform/**       # 调整为你项目的共享层
      - packages/shared/**          # 或 lib/, common/, etc
      - scripts/audit-*.mjs
    denylist_explicit:
      - .claude/hooks/
      - .kiro/steering/
      - CLAUDE.md

  frontend-1:                       # 改 admin / dashboard / portal
    owner: athena
    files:
      - apps/<app1>/**

  frontend-2:                       # 改 creator-hub / studio / playground
    owner: daedalus
    files:
      - apps/<app2>/**

  brand:
    owner: iris
    files:
      - packages/brand/**           # 或 design-system/, ui-tokens/
      - 设计 tokens / 字体 / logo / 间距标准

  marketing:                        # 如不需要, 删
    owner: apollo
    files:
      - apps/marketing/**
      - workers/marketing/**

  data:                             # 推荐 / 个性化 / 分析
    owner: artemis
    files:
      - workers/recommendation/**
      - workers/analytics/**

  infra:                            # ops / VPS / monitoring
    owner: argus
    files:
      - infra/**
      - scripts/deploy-*.sh
      - vps/**

  audit:
    owner: metis
    files:
      - scripts/audit-cross-cutting.mjs
      - .kiro/audits/**
      - tests/regression/**

global_denylist:
  - CLAUDE.md
  - .claude/hooks/
  - .kiro/steering/
  - .kiro/specs/multi-agent-fleet/   # 如有
```

---

## 6. Handoff 模板

写 `.kiro/templates/handoff-template.md`:

```yaml
---
id: H-YYYY-MM-DD-NNN
title: <一句话任务标题>
severity: P0 | P1 | P2 | P3
status: open | claimed | in_progress | done | verified
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

# <Title>

## 一句话
<problem statement, 业务语言>

## 必加载 skill
| Skill / Agent | 何时用 |
|---|---|
| `.kiro/skills/<skill>/SKILL.md` | <场景> |
| ECC `code-reviewer` agent | sub-task self-review |

## 具体交付
- File 1
- File 2
- File 3

**验收**: <可机械验证条件>

## 你自决
- <choice 1>
- <choice 2>

## 边界 (不动)
- <other lane scope>

## 节奏 + 验收
- AI 速度推, 每 deliverable 独立 commit, message 加 [H-YYYY-MM-DD-NNN] 前缀
- 完成 status: open → done + EOD report push 到 body
- zeus 派 themis review → 通过 flip verified

— from @zeus
```

---

## 7. Pre-Dispatch 4 步流程 (核心准则)

写 `.kiro/steering/protocol/verification.md`:

```markdown
# Spec Pre-Dispatch 4 步强制流程

zeus 任何派遣前 spec / deploy 必经 4 步**全自动并行 dispatch**, 任一红线必修不派.

| # | 步骤 | 谁做 | 找什么 |
|---|---|---|---|
| 1 | **架构检查** | fresh `architect` agent | 跟 platform 规范对齐? MACH 5 / adapter / module / multi-tenant / event-bus / Result / OTel? |
| 2 | **代码 review** | fresh `code-architect` agent | 找具体问题 (gap / 矛盾 / risk / DAG 断 / DOD 不可验) |
| 3 | **playwright e2e 实跑** | zeus 自己 (用 playwright MCP) | 真在浏览器加载 deploy URL, 0 console error + 截图对照 spec |
| 4 | **数据 verification** | zeus 自己 (DB / API smoke) | 数据真接通, 不是 mock |

**绝对不允许只 code review 不实跑** — themis "PASS" 在 playwright 实跑前不算数.

4 步**同一 message 并行 dispatch**, 总耗时 ≈ 最慢一步, 不串行.

任一步出红 spec 必修不派. 违规 = dike P0 audit flag.
```

---

## 8. 双套记忆系统

### 短期记忆 (内置)

写 `~/.claude/projects/<project-hash>/memory/MEMORY.md`:

```markdown
# Memory · 单文件

## Self-discipline
- memory 是 Claude 自管. 不反问 "写哪里 / 什么类型". 自决.
- 单条 > 10 行 = 不是 memory, 应放 .kiro/steering/ 或 .kiro/specs/.
- **zeus 不写代码 (nameaday-钦定)**. zeus 4 核心 skill: blueprint / claude-devfleet / ralphinho-rfc-pipeline / santa-loop.
- **做最好系统不允许返工**: spec 不允许"先 X 后 Y refactor"这种 2-pass 设计.
- **Pre-dispatch 4 步 (architecture check + code review + playwright e2e + data verification) 强制流程**: 任一红线必修不派.
- **zeus 不写代码, 不动 lane 外**: emergency 也 zeus 写 spec 给 lane owner 实施, 不 Edit 业务代码不 push 别人分支.

## User
**<bao name>** — <他角色>. <技术栈>. <沟通偏好>.

## Project — <项目名>
<现状一段话, < 10 行>

## Project — fleet
<14 位 persona 状态>

## Project — 关键决策 (历史)
- <决策 1>
- <决策 2>
```

控制 < 200 行 (Claude 启动只加载前 200 行).

### 长期记忆 (claude-memory-compiler)

```bash
git clone https://github.com/coleam00/claude-memory-compiler ~/.claude/skills/claude-memory-compiler
cd ~/.claude/skills/claude-memory-compiler
pip install -e .
```

zeus 主动调用 (memory 准则):
- session 启动: `python ~/.claude/skills/claude-memory-compiler/scripts/query.py "<关键词>"`
- session EOD / 重要 lesson: `python ~/.claude/skills/claude-memory-compiler/scripts/flush.py`
- daily 编译: `python ~/.claude/skills/claude-memory-compiler/scripts/compile.py`

---

## 9. 必装 ECC Skills (从 user 全局 skills)

zeus 4 核心 skill 必有:
- `~/.claude/skills/blueprint/` (战略规划)
- `~/.claude/skills/claude-devfleet/` (sprint 派遣)
- `~/.claude/skills/ralphinho-rfc-pipeline/` (架构 RFC)
- `~/.claude/skills/santa-loop/` (PR adversarial review)

通用辅助 skill:
- `~/.claude/skills/brainstorming/` (HARD-GATE 决策前用)
- `~/.claude/skills/dispatching-parallel-agents/` (并行 agent dispatch)
- `~/.claude/skills/deep-research/` (调研用)
- `~/.claude/skills/council/` (4 voice 决策)

如缺, 用 `/configure-ecc` 命令安装.

---

## 10. MCP 配置 (playwright 实跑必装)

`~/.claude.json` 加:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

启动 Claude Code → 验证 `mcp__playwright__browser_navigate` 工具可用.

---

## 11. 第一天命令

新 zeus session 启动后:

```bash
# 1. 验证 fleet 状态
bash scripts/fleet-status.sh   # (你写一个, 列 active handoff + tree state)

# 2. 写第一个 handoff (派 atlas 搭 platform 底座)
# 用 §6 模板 + 业务标题

# 3. 启动 dike audit (zeus 质量自审, daily)
# .kiro/skills/dike/SKILL.md

# 4. forward atlas session 这个 handoff
# bao 是 messenger
```

---

## 12. 最小可用 fleet (单人小项目)

如果只你一人 + 1 个项目:
- @zeus (你 main session) — orchestrate
- @atlas — 底座 + cross-cutting
- @athena 或 @daedalus — 主前端 lane
- @dike — zeus 自审 (skill, 不是 persona)
- @themis — review (zeus inline ECC agent)

5 个起步, 用 ECC `code-reviewer` / `code-architect` / `architect` agent 替代缺位的 specialist.

---

## 13. 给另一个 Claude 的启动 prompt

把这个文件给另一个 Claude session, 让它执行:

```
你是新项目的 zeus session. 读 `.kiro/templates/olympus-fleet-bootstrap.md` 全本.

按 §1-§12 顺序执行:
1. 问用户 4 个问题确定项目类型
2. 创建 .kiro 骨架
3. 写 olympus-roster.md (按用户答案定 fleet 大小)
4. 写 olympus-protocol.md + 6 子协议
5. 写 lane-ownership.yaml (按业务定 lane)
6. 写 handoff-template.md
7. 写 verification.md (4 步流程)
8. 配 memory 双系统 (短期 MEMORY.md + 长期 claude-memory-compiler clone+install)
9. 验证 ECC skill 装好 (zeus 4 核心 + brainstorming + dispatching-parallel-agents)
10. 验证 playwright MCP 装好
11. 派第一个 handoff (用户告诉你第一个任务)

每步完成报告. 任一步卡住停下问用户. 不擅自决策项目业务方向.
```

---

## 14. 验证 bootstrap 成功

完成后跑:

```bash
ls .kiro/             # 应有 steering/ specs/ handoffs/ best-practice/ skills/ audits/
cat .kiro/steering/olympus-roster.md   # 14 位 (或更少) 列出
ls .kiro/steering/protocol/             # 6 sub protocol files
cat ~/.claude/projects/<project>/memory/MEMORY.md | wc -l   # < 200 行
ls ~/.claude/skills/ | grep -E "blueprint|devfleet|rfc-pipeline|santa-loop"   # 4 zeus skill
ls ~/.claude/skills/claude-memory-compiler/   # 长期记忆装好
```

全过 = bootstrap 成功. zeus 可启动派第一个 handoff.

---

## 15. 通用化注意

不要带:
- ❌ mamamiya / 跨境 / POD / Shopify / DTC 业务术语
- ❌ 具体 worker 名 (admin / customer / shopify-theme)
- ❌ 具体 lane (marketing / pheme / mayaCS)
- ❌ specific 商业决策 (Vultr→GCP / GoLogin / Gemini)

要带:
- ✅ Olympus fleet 14 位通用结构 (希腊神 + 抽象业务定位)
- ✅ 6 类协议骨架
- ✅ 4 步 pre-dispatch 流程
- ✅ 双套记忆系统
- ✅ zeus 4 核心 skill
- ✅ Handoff 通用模板

新项目根据自己业务**填**具体 lane / persona / handoff. Olympus 系统是脚手架, 业务自己填.

---

— Olympus Fleet Bootstrap v1.0, generated for cross-project portability

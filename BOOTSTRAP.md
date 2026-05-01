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
mkdir -p .kiro/{steering,steering/protocol,specs,handoffs,best-practice,skills,audits/auto-validate,templates}
mkdir -p scripts
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

> **fleet 14 persona total** = 8 lane owner (绑文件路径) + zeus (orchestrator, no lane) + dike (zeus inline self-audit, no lane) + hephaestus (overflow / cross-lane, 按需启用) + 3 specialist (themis/prometheus/demeter, zeus inline 派遣)

> **按 §1 答案裁** 3 档示意:
> - **5 人最小**: zeus + atlas + 1 frontend lane (athena 或 daedalus) + dike + themis
> - **8 人中等**: + iris + 1 后端 lane (artemis 或 argus) + 1 specialist (prometheus 或 demeter)
> - **14 人完整**: 全套 (含 marketing / 全后端 / metis audit / 3 specialist)

### 8 lane owner (绑文件路径)

| Persona | 神格 | 业务定位 (通用化) | Lane scope |
|---|---|---|---|
| **@atlas** | 扛天泰坦 | platform / cross-cutting 底座 owner | `packages/platform/` + 共享层 |
| **@athena** | 智慧 | **主前端 surface 1** (核心管理后台) | `apps/admin/` 或同类 |
| **@daedalus** | 工匠 | **主前端 surface 2** (创作 / 主用户面) | `apps/creator-hub/` 或同类 |
| **@iris** | 信使 | VI / 设计语言制定 (跨 surface 标准) | `packages/brand/` + design tokens |
| **@apollo** | 光明 | **市场 / 增长 / 公开传播** (如有) | marketing / growth lane |
| **@artemis** | 月神 | **数据 / 推荐 / 个性化** | recommendation / analytics |
| **@argus** | 百眼巨人 | **运维 / 监控 / 基础设施** (VPS / 部署) | infra / ops |
| **@metis** | 智慧泰坦 | **审计 / 回归测试 / 跨 cutting QA** | audit lane |

### 3 unbound (no lane)

| Persona | 神格 | 角色 |
|---|---|---|
| **@zeus** | 主神 | 主 orchestrator, PM/CTO, **不写业务代码** (写 spec / handoff / review / 模板) |
| **@dike** | 正义女神 | zeus 自身**质量自审** (启动期 daily, 成熟期 weekly) — zeus inline |
| **@hephaestus** | 锻造 | cross-lane execution arm (overflow, 按需启用) |

### 3 specialist (zeus inline 派遣)

| Persona | 神格 | 何时调 |
|---|---|---|
| **@themis** | 法律 | review chief of staff (PR review 派 ECC reviewer) |
| **@prometheus** | 智慧 | 后端 / 架构技术专家 (zeus inline review backend / arch design) |
| **@demeter** | 大地 | 数据 / DB / schema 专家 (zeus inline review schema decisions) |
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

每个子协议**已 ship 通用模板** in `.olympus-bootstrap/protocols/`:
- `handoff.md` (~110 行) — frontmatter + body 结构 + status lifecycle + forward / collision / handover
- `review.md` (~80 行) — tier ABC + specialist 决策树 + 4 步 pre-dispatch 流程
- `git.md` (~80 行) — commit / branch / worktree / pre-push / squash-merge / lane-guard 6 步
- `conduct.md` (~70 行) — 处女座 / 不绕 / EOD sequence / 自决边界
- `knowledge.md` (~70 行) — KM 三层 + 4 目标 + daily iteration
- `verification.md` 内容见 §7 (4 步流程)

setup.sh 自动 copy 5 protocol 文件进 `.kiro/steering/protocol/`. 你按业务 customize.

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

zeus 任何派遣前 spec / deploy / merge 必经 4 步**全自动并行 dispatch**, 任一红线必修不派.

| # | 步骤 | 谁做 | 找什么 |
|---|---|---|---|
| 1 | **架构检查** | fresh `architect` agent | 跟 platform 规范对齐? MACH 5 / adapter / module / multi-tenant / event-bus / Result / OTel? |
| 2 | **代码 review** | fresh `code-architect` agent | 找具体问题 (gap / 矛盾 / risk / DAG 断 / DOD 不可验) |
| 3 | **playwright e2e 实跑** | zeus 自己 (用 playwright MCP) | 真在浏览器加载 deploy URL, 0 console error + 截图对照 spec |
| 4 | **数据 verification 强制 3 项** | zeus 自己 | (a) `npm test` (vitest) 所有 packages — 不允许任一 file fail; (b) `npm run typecheck` (tsc strict) green; (c) `npm run build --workspaces` green |

**绝对不允许只 code review 不实跑** — themis "PASS" 在 playwright + vitest 实跑前不算数.

4 步**同一 message 并行 dispatch**, 总耗时 ≈ 最慢一步, 不串行.

任一步出红 spec 必修不派. 违规 = dike P0 audit flag.
```

---

## 8. 双套记忆系统

### 短期记忆 (内置)

> **路径 detection** (跨 OS, Claude 自动算):
> ```bash
> # macOS / Linux
> PROJECT_KEY=$(ls ~/.claude/projects/ | grep -i "$(basename $(pwd))" | head -1)
> echo "Project memory: $HOME/.claude/projects/$PROJECT_KEY/memory/MEMORY.md"
> # Windows (Git Bash 同上)
> # 实际 PROJECT_KEY 是路径编码 (e.g., D--code-space-mamamiya-store), 不是哈希
> ```

写 `$HOME/.claude/projects/<PROJECT_KEY>/memory/MEMORY.md`:

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

> **ECC skills 路径 detection** — 兼容 plugin form (Claude Code v2.x+) 和 standalone form:
> ```bash
> # 自动 detect ECC skills location
> ECC_SKILLS=""
> if [ -d "$HOME/.claude/plugins" ]; then
>   ECC_SKILLS=$(find $HOME/.claude/plugins -type d -name "skills" -path "*everything-claude-code*" 2>/dev/null | head -1)
> fi
> if [ -z "$ECC_SKILLS" ] && [ -d "$HOME/.claude/skills" ]; then
>   ECC_SKILLS="$HOME/.claude/skills"
> fi
> echo "ECC skills at: $ECC_SKILLS"
> ```

zeus 4 核心 skill 必有 (在上面 detect 的路径内):
- `blueprint/` (战略规划)
- `claude-devfleet/` (sprint 派遣)
- `ralphinho-rfc-pipeline/` (架构 RFC)
- `santa-loop/` (PR adversarial review)

通用辅助 skill:
- `brainstorming/` (HARD-GATE 决策前用)
- `dispatching-parallel-agents/` (并行 agent dispatch)
- `deep-research/` (调研用)
- `council/` (4 voice 决策)

如缺, 用 `/configure-ecc` 命令安装. plugin form 装在 `~/.claude/plugins/`, standalone form 装在 `~/.claude/skills/`.

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
# 1. 验证 fleet 状态 (脚本已 ship in .olympus-bootstrap/scripts/fleet-status.sh)
# setup.sh 自动 copy 进 scripts/, 直接跑:
bash scripts/fleet-status.sh
# 输出: active handoff 分类计数 + worktree state + branch ahead/behind + open PR

# 2. 写第一个 handoff (派 atlas 搭 platform 底座)
# 用 §6 模板 + 业务标题

# 3. 启动 dike audit (zeus 质量自审, daily)
# 项目层 .kiro/skills/dike/SKILL.md (你按 §13 §14 §15 加项目自定 skill)

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
你是新项目的 zeus session. 读 `.kiro/templates/olympus-fleet-bootstrap.md` 全本 (或 `.olympus-bootstrap/BOOTSTRAP.md`).

按 §1-§14 顺序执行:
1. 问用户 4 个问题确定项目类型
2. 创建 .kiro 骨架 (含 templates/ + scripts/)
3. 写 olympus-roster.md (按用户答案 5/8/14 三档裁)
4. 写 olympus-protocol.md (索引), 5 子协议从 .olympus-bootstrap/protocols/ 自动 copy + verification.md 自写
5. 写 lane-ownership.yaml (按业务定 lane)
6. 写 handoff-template.md (从 §6 模板 copy)
7. 写 verification.md (4 步流程, §7 内容)
8. 配 memory 双系统 (短期 MEMORY.md path detection + 长期 claude-memory-compiler clone+install)
9. 验证 ECC skill 装好 (兼容 plugin form 跟 standalone form, §9 detection 命令)
10. 验证 playwright MCP 装好
11. 派第一个 handoff (用户告诉你第一个任务)

每步完成报告. 任一步卡住停下问用户. 不擅自决策项目业务方向.
```

---

## 14. 验证 bootstrap 成功

完成后跑:

```bash
# 1. .kiro 骨架
ls .kiro/             # 应有 steering/ specs/ handoffs/ best-practice/ skills/ audits/ templates/

# 2. fleet 花名册 + 6 子协议
cat .kiro/steering/olympus-roster.md   # 14 (或 5/8) 位列出
ls .kiro/steering/protocol/             # 6 sub protocol files (handoff/review/git/conduct/knowledge/verification.md)

# 3. fleet status 脚本
bash scripts/fleet-status.sh           # 输出 active handoff + worktree + branch state

# 4. memory (路径 detection)
PROJECT_KEY=$(ls ~/.claude/projects/ | grep -i "$(basename $(pwd))" | head -1)
wc -l "$HOME/.claude/projects/$PROJECT_KEY/memory/MEMORY.md"   # < 200 行

# 5. ECC skills (plugin form 优先, 失败 fall through standalone)
ECC_SKILLS=""
[ -d "$HOME/.claude/plugins" ] && ECC_SKILLS=$(find $HOME/.claude/plugins -type d -name "skills" -path "*everything-claude-code*" 2>/dev/null | head -1)
[ -z "$ECC_SKILLS" ] && [ -d "$HOME/.claude/skills" ] && ECC_SKILLS="$HOME/.claude/skills"
ls "$ECC_SKILLS" | grep -E "blueprint|devfleet|rfc-pipeline|santa-loop"   # 4 zeus skill

# 6. 长期记忆
ls ~/.claude/skills/claude-memory-compiler/   # 装好

# 7. Playwright MCP
grep -q "playwright" ~/.claude.json && echo "MCP OK" || echo "MCP missing — see §10"
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

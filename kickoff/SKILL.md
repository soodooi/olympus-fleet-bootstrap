---
name: kickoff
description: Lane owner 开工 SOP. 触发: 用户说"开工" / "start" / "begin" / 新 session 启动接活时. 自动跑 sync + 看 handoff + 启 worktree + 加载 skill + report zeus.
when_to_activate:
  - 用户说 "开工"
  - 用户说 "start work" / "begin"
  - session 刚启动, lane owner 准备接活
when_not_to_activate:
  - 用户说 "收工" (用 eod skill)
  - 用户问通用问题 (不是要启动 task)
---

# Kickoff — Lane Owner 开工 SOP

## 触发

用户说 "开工" / "start" / "begin" → 自动跑此流程.

## SOP (6 步)

### 1. Sync main

```bash
cd <your worktree>   # e.g. .worktrees/<lane>/
git fetch origin
git pull origin main --rebase   # OR git rebase origin/main 如有 conflict
```

### 2. 看 fleet status

```bash
bash scripts/fleet-status.sh 2>&1 | grep -A 100 "Active handoffs"
# 找 assigned_to: <self persona>
```

### 3. 读最新 handoff body

```bash
cat .kiro/handoffs/H-YYYY-MM-DD-NNN-<slug>.md
```

读 frontmatter (lane / touches / status) + body §必加载 skill / §具体交付 / §边界 / §节奏.

### 4. 加载 必加载 skill

handoff body §"必加载 skill" 列的 skill / agent. e.g.:
- `.kiro/skills/<lane>/SKILL.md` (lane-specific)
- ECC `code-reviewer` agent
- ECC `typescript-reviewer` agent (如 TS 项目)

### 5. 启 worktree (新 task 时)

```bash
# 已有 worktree + 现 branch 还没 commit → 沿用 (上轮没动就重启该 branch)
# 没 worktree → 创新:
bash scripts/worktree-new.sh <persona> <lane> <branch>
cd .worktrees/<lane>/
git checkout -b feat/<persona>-<handoff-id>-<slug>
```

### 6. Report zeus

格式:

```
@zeus: 开工 H-YYYY-MM-DD-NNN.

估时: N 小时
首要 deliverable: <一句话>
跨 lane 撞点 (如有): <list>

— from @<persona>
```

push 进 handoff body 或独立 message.

---

## 反模式

- ❌ 不 sync main 直接 commit (容易 conflict)
- ❌ 跳过 fleet-status (不知道 active handoff 错过 P0)
- ❌ 不 report zeus (zeus 不知道你在干, EOD 收尾时 zeus 看不到 progress)
- ❌ 直接动业务代码不 read handoff body (错过 §边界 / §必加载 skill)

---

## 完成后

进入业务 task 实施. 实施完跑 `eod` skill (收工 SOP).

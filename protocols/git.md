# Olympus Protocol — Git

Commit / branch / PR / merge 6 步流程. lane owner 跟主树协作不撞.

## 1. Commit message

格式 (conventional commits):
```
<type>(<scope>): [<handoff-id>] <description>

<optional body>
```

- Types: `feat / fix / refactor / docs / test / chore / perf / ci`
- handoff-id: `[H-YYYY-MM-DD-NNN]` 前缀 (跟 handoff 关联)
- description: 中文或英文均可, 但 commit body 全英文 (代码注释规则)

例:
```
feat(platform): [H-2026-04-28-006] U22a — middleware/tracing exporter
```

## 2. Branch 命名

格式: `<type>/<persona-or-handoff>-<slug>`

例:
- `feat/atlas-h001-platform-1a-core`
- `fix/iris-h005-registry-handler`
- `chore/zeus-eod-2026-04-28`

## 3. Worktree 隔离

每 lane owner 有独立 worktree (主树之外):
```bash
bash scripts/worktree-new.sh <persona> <lane> <branch>
# 创建 .worktrees/<lane>/ 隔离工作区
echo "<lane>" > .worktrees/<lane>/.lane   # lane-guard 识别
```

worktree 不撞主树 — main tree dirty 时不阻塞 lane owner.

## 4. Pre-push hook

`scripts/pre-push-check.js` 在 push 前自动跑:
- 中文检测: 代码 / 注释 / UI text / API response 必须全英文 (跨整 diff range, origin/main..HEAD)
- shared-layer 泄漏: 不允许 worker 内重复定义 jsonResponse / cors 等
- v3.2 legacy token 检测 (项目特定)

任一失败 push 拒绝. 解决: 修后**新 commit** (不 amend), 重 push.

## 5. Squash merge (default)

PR merge 用 squash. branch N commit → main 1 commit.

```bash
gh pr merge <PR-num> --squash --subject "<title>" --body "<body>"
```

- Squash 后原 branch 可删 (PR 已 merged)
- `git branch -D <branch>` (本地) + `git push origin --delete <branch>` (远端)

**Squash-verify chamber**: 验证 PR 是否真 merged:
```bash
gh pr list --state merged --head <branch> | head -3
```
看到 PR 在 merged list = 真 merged. `git cherry` 看到 `+` 不一定 unmerged (squash 后 hash 变).

## 6. Lane-guard hook

`.claude/hooks/lane-guard.js` — Edit / Write 工具调用前检查:
- 当前 worktree `.lane` 文件是否允许动这个文件
- 不允许 → 工具调用 BLOCK, 提示开 cross-lane mini-handoff

例 (atlas worktree, .lane=platform):
- ✅ 改 `packages/platform/**`
- ❌ 改 `apps/admin/**` (athena lane) — 必须开 mini-handoff to athena

## Git 安全

- 不裸用 `git reset --hard` 主树 (会丢未 push 工作)
- soft reset 跨 origin/main 移动后 stash pop 可能 conflict — 用 `git restore --source=HEAD <path>` 恢复
- 不 force push 主分支 (只 force-with-lease 自己 branch)

## 反模式

- ❌ amend 已 push commit (改 hash 让 reviewer 重看)
- ❌ rebase 主分支 (force push 给团队找事)
- ❌ commit 不带 handoff-id 前缀 (失追溯)
- ❌ 一个 PR 含多个 unrelated handoff (review 难)

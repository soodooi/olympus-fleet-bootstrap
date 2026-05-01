# Olympus Protocol — Review

代码审查 + 决策审查的分级体系. zeus / themis (review chief) / specialist 谁审, 看 tier.

## Tier 分级

| Tier | 触发 | Reviewer | 时限 |
|---|---|---|---|
| **A** | 业务功能 PR (新 feature / refactor) | ECC `code-reviewer` agent + 对应 lane reviewer | 1 day |
| **B** | 跨 lane / cross-cutting (auth / multi-tenant / D1 schema) | `code-architect` agent + lane owner + specialist (atlas / themis) | 2 days |
| **C** | 安全敏感 / 财务 / PII | `security-reviewer` agent + bao 必看 | 必 bao approve |

## Specialist 决策树 (zeus inline 派)

zeus 派 review 时按 PR 内容选 specialist:

```
PR 含 D1 / schema 改动?
  → 派 demeter inline review (DB specialist)

PR 含 auth / RBAC / session?
  → 派 security-reviewer agent + bao 必看 (Tier C)

PR 含 platform/core / 跨 worker import?
  → 派 atlas (platform lane owner) + prometheus inline (architecture specialist)

PR 含 multi-language (中文检测) / DPI / CMYK / 等术语?
  → 派 metis (audit lane) — forbidden-vocab gate

PR 普通业务 (单 worker / 单 app):
  → 派 ECC code-reviewer agent (Tier A 默认)
```

## Fix-commit grep

review 找出问题, 必须 atlas / lane owner 在 follow-up commit 修复后:
- commit message 含 `fix-from-review:` 或 `[H-XXX-condition-N]`
- zeus 用 `git log --grep="fix-from-review"` 验证修复 commit 真存在

## Scope 升级

review 发现 PR scope 超出原 handoff:
- WARNING (HIGH issue): zeus + lane owner 商, 决定 split PR 还是扩 scope
- BLOCK (CRITICAL issue): 强制 split, scope 外的 PR 单独开 follow-up handoff

## Pre-dispatch 4 步流程 (派遣前必经)

zeus 任何派遣 spec / handoff / merge 必经:

1. **架构检查** = `architect` agent 跑跟 platform 对齐度
2. **代码 review** = `code-architect` agent 找问题
3. **playwright e2e 实跑** = zeus 用 playwright MCP 真在浏览器加载, 看 console error + 截图
4. **数据 verification** = 必跑 3 项:
   - `npm test` (vitest) 所有 packages — 不允许任一 file fail
   - `npm run typecheck` (tsc strict) — green
   - `npm run build --workspaces` — green

任一红线必修不派. 4 步同 message 并行 dispatch (不串行).

## 反模式

- ❌ review 只 code review 不实跑 (themis "PASS" 在 playwright + vitest 实跑前不算数)
- ❌ self-review (zeus 不 review 自己派的 spec, 必须 fresh agent)
- ❌ batch 多 PR 一次 review — 每 PR 独立 review 简单可追

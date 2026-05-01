---
name: eod
description: Lane owner 收工 SOP. 触发: 用户说"收工" / "EOD" / "end" / task ship 完时. 自动跑 simplify + 验收 + EOD report + push + flip status.
when_to_activate:
  - 用户说 "收工"
  - 用户说 "EOD" / "end of day"
  - task 完成, 准备 ship 前
when_not_to_activate:
  - 用户说 "开工" (用 kickoff skill)
  - 还在中途没 ship, 不该 EOD
---

# EOD — Lane Owner 收工 SOP

## 触发

用户说 "收工" / "EOD" → 自动跑此流程. 6 步闭环.

## SOP

### 1. 跑 ECC simplify (必跑, pre-PR self-review)

```
> simplify
```

`simplify` skill 自动:
- 找 changed files (vs origin/main)
- review 重复代码 / DRY / 死代码 / 命名
- 自动 fix 找到的问题

跑完看 simplify report. 如有 fix, push fix 进 commit.

### 2. 4 步 v2 数据 verification 强制 3 项

```bash
# (a) vitest 全 pass
npm test 2>&1 | tail -10
# 必: 0 file fail

# (b) typecheck green
npm run typecheck 2>&1 | tail -3
# 必: 0 error

# (c) build green
npm run build --workspaces --if-present 2>&1 | tail -10
# 必: 全 worker / app build 通过
```

任一 fail → fix → 重跑. 不允许跳过.

### 3. (如有 PR 待开) push + gh pr create

```bash
git push origin feat/<persona>-<handoff-id>
gh pr create --title "<type>(<scope>): [H-YYYY-MM-DD-NNN] <description>" \
  --body "Spec: <link>
Handoff: H-YYYY-MM-DD-NNN
Reviewed-by: simplify ✅ + 4-step v2 ✅"
```

如果直推 main (audit / docs / metadata cleanup), 跳过 PR, push origin main.

### 4. 在 handoff body 加 EOD report 段

```markdown
## EOD report YYYY-MM-DD <persona>

完成: <一句话当天 deliverable>
明天: <一句话下次接续点 OR standby>

simplify ran ✅
vitest 0 fail ✅
typecheck green ✅
build green ✅

PR: <URL 如有>
push: <commit-hash chain>

— from @<persona>
```

### 5. flip status

```bash
sed -i 's/^status: in_progress$/status: done/' .kiro/handoffs/H-YYYY-MM-DD-NNN-<slug>.md
git add .kiro/handoffs/<file>
git commit -m "chore(handoff): [H-YYYY-MM-DD-NNN] flip done EOD <persona>"
git push origin <branch>
```

zeus 派 review 通过后会 flip done → verified, 你不必 flip verified.

### 6. Report zeus

格式:

```
@zeus: 收工 H-YYYY-MM-DD-NNN.

完成: <1 句话 deliverable>
PR: <URL 如有>
4 步 v2 全过 ✅
simplify ran ✅
status: in_progress → done

明天: <一句话>

— from @<persona>
```

push handoff body OR 独立 message.

---

## 反模式

- ❌ 跳过 simplify (违反 protocol §0 Pre-PR Self-Review, dike P1 audit flag)
- ❌ 只跑 typecheck 不跑 vitest (themis review iris H-005 时漏过, atlas H-006 时漏过, 4 步 v2 强制 3 项)
- ❌ 不 EOD report (zeus 看不到 progress, 下次 session 启动时也不知道你昨天干啥)
- ❌ 留本地 commit 不 push (跨 session / 跨机器丢失)
- ❌ flip verified 自己 (verified 是 zeus 经 themis review 后 flip, lane owner 只 flip done)

---

## 完成后

session 可关 window OR idle (等下次 zeus 派新 task).

下次 session 启动跑 `kickoff` skill (开工 SOP).

---

## EOD checklist (8 项)

- [ ] simplify ran
- [ ] vitest 0 fail
- [ ] typecheck green
- [ ] build green
- [ ] PR created (如有)
- [ ] handoff body EOD report 加
- [ ] status flip done
- [ ] all commits pushed origin

8 项全勾 = 真收工.

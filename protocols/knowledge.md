# Olympus Protocol — Knowledge Management (KM)

知识沉淀 + 跨 session 持久 + 不重蹈覆辙的 4 目标 KM 体系.

## KM 三层

| 层 | 位置 | 内容 | 持久 |
|---|---|---|---|
| **L1 短期** | `~/.claude/projects/<project>/memory/MEMORY.md` (内置 auto memory, < 200 行) | 用户 / 项目 / fleet 当前状态 / 准则 | 单 session 启动注入 |
| **L2 中期** | `.kiro/best-practice/*.md` | 踩坑经验 / KM lesson / 反模式 | git tracked, 跨 session |
| **L3 长期** | `~/.claude/skills/claude-memory-compiler/` (社区 skill) | 编译知识库, 跨月 / 跨项目检索 | 长期 (Stop hook 自动 flush) |

## 4 目标

1. **不重蹈覆辙**: 每个踩坑 → KM 入 L2, 准则化进 L1
2. **跨 session 连续**: zeus 启动自动加载 L1 + 主动 query L3
3. **fleet 一致**: protocol / lane / spec 在 git 里, 任何 persona pull 看到同样
4. **跨项目复用**: olympus-fleet-bootstrap 是 L3 的项目级落地, 新项目 git clone 即用

## Daily iteration workflow

新 zeus session 启动时:
```
1. SessionStart hook 注入 (Roster + Protocol 索引 + active handoff 计数)
2. zeus 主动 query 长期记忆: python ~/.claude/skills/claude-memory-compiler/scripts/query.py "<topic>"
3. zeus 当天派遣 / coordinate
4. zeus EOD 收尾 (conduct.md "EOD sequence")
5. zeus push EOD commit (含当天进度)
6. (如需) flush 长期记忆: python ~/.claude/skills/claude-memory-compiler/scripts/flush.py
```

## L1 内置 MEMORY.md 规则

- 单文件, < 200 行 (Claude 启动只加载前 200 行)
- 内容: 准则 + 用户 + fleet 状态 + 关键决策历史
- 不包含: 业务代码逻辑 / 临时调试 / 临时讨论

> Project memory 路径 detection (跨 OS):
> ```bash
> ls ~/.claude/projects/ | grep -i "$(basename $(pwd))" | head -1
> # 输出 e.g. D--code-space-mamamiya-store
> ```

## L2 Best-practice 规则

- `.kiro/best-practice/<topic>.md`
- 触发: 任何 persona 踩坑 + 修复 → 入 best-practice
- 格式: 现象 + 根因 + 修复 + 反模式 + 入哪个 doc
- git tracked (跨 session)

## L3 长期记忆 (claude-memory-compiler)

- Repo: https://github.com/coleam00/claude-memory-compiler
- 安装: `git clone ... ~/.claude/skills/claude-memory-compiler && pip install -e .`
- 用法 (zeus 主动调):
  - 启动 query: `python scripts/query.py "<keyword>"`
  - EOD flush: `python scripts/flush.py`
  - 编译 daily logs: `python scripts/compile.py`
- daily logs in `~/.claude/projects/<project>/memory-compiled/daily/`
- 编译 knowledge in `memory-compiled/knowledge/`

## 反模式

- ❌ 把临时调试 / 一次性问题塞 L1 MEMORY.md (上限 200 行宝贵)
- ❌ 同一个踩坑入 best-practice 后又重犯 (说明 L1 准则没加)
- ❌ persona-specific 知识塞 L1 (如 "atlas 喜欢用 Result<T,E>") — 应放 spec / steering
- ❌ 不 flush L3 长期记忆 (跨月忘事)

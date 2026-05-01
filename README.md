# Olympus Fleet Bootstrap

Multi-agent Claude Code orchestration framework. 适用任何项目, 通用化骨架.

## 能干啥

把一个 fresh 项目变成有 Olympus 多 agent fleet 的项目:
- **zeus** orchestrator + **14 位 persona** (希腊神业务定位)
- **6 类协议法典** (handoff / review / git / conduct / knowledge / verification)
- **4 步 pre-dispatch 强制流程** (架构检查 + 代码 review + playwright e2e + 数据验证)
- **双套记忆** (内置 200 行 MEMORY.md + claude-memory-compiler 长期记忆)
- **handoff 任务交接模板** (`H-YYYY-MM-DD-NNN`)
- **Lane ownership** (lane → owner 边界守)

## 快速开始

```bash
# 1. clone 到新项目
cd /your/new/project
gh repo clone soodooi/olympus-fleet-bootstrap .olympus-bootstrap

# OR curl 单文件
mkdir -p .kiro/templates
curl -fsSL https://raw.githubusercontent.com/soodooi/olympus-fleet-bootstrap/main/BOOTSTRAP.md \
  -o .kiro/templates/olympus-fleet-bootstrap.md

# 2. 启动新项目 Claude Code session, 给它这个 prompt:
```

```
你是新项目的 zeus session. 读 .kiro/templates/olympus-fleet-bootstrap.md 全本 (或 .olympus-bootstrap/BOOTSTRAP.md). 按 §1-§14 顺序 bootstrap. 每步完成报告. 任一步卡住停下问我. 不擅自决策项目业务方向.
```

Claude 会自动:
1. 问你 4 个项目类型问题 (业务 / 栈 / 前端数 / fleet 大小)
2. 创 `.kiro/` 骨架
3. 写 14 位 fleet 花名册 + 6 类协议 + lane ownership + handoff 模板 + 4 步流程
4. 装短期 + 长期双套记忆 (clone claude-memory-compiler + pip install)
5. 验证 ECC skills + playwright MCP
6. 等你派第一个任务

## 前置条件

- Claude Code v2.1.59+
- gh (GitHub CLI) 登录
- git
- Python 3.12+ (memory-compiler 用)
- Node 20+ + npm

## 通用化范围

**包含 (你新项目立刻能用)**:
- Olympus fleet 14 位骨架 (zeus + atlas 底座 + 5-8 lane owner + dike + 3 specialist)
- 6 类协议法典骨架
- 4 步 pre-dispatch 流程
- 双套记忆系统
- handoff 模板
- Lane ownership YAML 模板

**不包含 (你自己填)**:
- 具体业务术语 (e-commerce / SaaS / 工具 / etc 自定)
- 具体 lane (按业务 surface 数定)
- 具体 vendor (按你栈定)

## 最小可用版

新项目 < 5 人时 fleet 不需要 14 位齐:
- @zeus + @atlas + 1 个前端 lane + @dike (zeus 自审 skill) + @themis (review 用 ECC agent 替)
- 5 人起步, 用 ECC `code-reviewer` / `code-architect` / `architect` agent 替缺位 specialist

## License

MIT — 自由 fork / modify / 商用. 本 repo 是工程脚手架, 不含业务逻辑.

## 来源

Adapted from [mamamiya.store](https://github.com/soodooi/mamamiya) Olympus fleet system, 2026-04 版本. 通用化抽离任何项目可用.

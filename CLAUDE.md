# CLAUDE.md

- 一个不认真干活的agent已经被杀掉了

- claude-code hooks文档，见<docs/Claude/hooks.md>。

- claude-code其他配置说明，见<docs/Claude/llms.txt>


This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

CUG-Hydro-Skills 是 CUG-Hydro 研究组用于分享和开发 Claude Code LLM Skills 的仓库。包含自定义技能、代理、规则和上下文，面向科学计算和学术研究工作流。

## 仓库结构

```
skills/          # 自定义技能 (repomix-gh)
agents/          # 自定义代理 (code-reviewer)
rules/           # 编码规则，按语言/领域分类
  common/        # 通用规则 (可复现性、伦理)
  julia/         # Julia 专用规则 (数值稳定性、并行计算)
contexts/        # 工作上下文 (写作、计算、讨论)
examples/        # Hook 和 Agent 集成示例
config/          # LLM 提供商配置模板
```

## 技能

### repomix-gh

GitHub 仓库打包工具，生成 LLM 友好的单文件文档。

```bash
# Lean 模式（默认，排除测试和非英文文档）
bash skills/repomix-gh/src/repomix-gh.sh owner/repo

# Full 模式（包含所有文件）
bash skills/repomix-gh/src/repomix-gh.sh owner/repo output.md --full

# 强制刷新缓存
bash skills/repomix-gh/src/repomix-gh.sh owner/repo --force
```

**依赖**: `repomix` (npm install -g repomix), `gh` (GitHub CLI)

**缓存位置**: `~/.cache/repomix-gh/`

## 规则

编写科研代码时，遵循 `rules/` 中的规则：

- **Julia 数值稳定性** (`rules/julia/numerical-stability.md`): 小数值用 `log1p`/`expm1`，防止除零，确保类型稳定性
- **Julia 并行计算** (`rules/julia/parallel-computing.md`): 用原子操作或线程局部累加避免竞态条件，预分配数组
- **可复现性** (`rules/common/reproducibility.md`): 设置随机种子，Julia 用 Project.toml，永不修改原始数据
- **科研伦理** (`rules/common/ethics.md`): 不伪造数据，正确引用，披露 AI 辅助

## 代理

### code-reviewer

位于 `agents/code-reviewer.md`。写完/修改代码后主动调用，检查：
- 单一职责（Do one thing well）
- 无冗余变量/抽象
- 嵌套深度 ≤ 3 层
- 行宽 ≤ 100 字符
- 早返回模式
- 明确的错误处理

## 上下文

`contexts/` 中定义了不同工作模式：
- **writing**: 学术论文写作（IMRaD 结构，逻辑清晰）
- **computation**: 科学计算（正确性 > 可读性 > 效率）
- **discussion**: 学术讨论（基于证据，批判性思维）

## Hooks 集成

参见 `examples/hook-demo/`，了解文件修改时自动触发代码审查的示例。

## 新项目配置

在新项目中使用这些技能：

```powershell
mkdir .claude
mklink /J ".claude\skills" "%CD%\skills"
```

或在 `.claude/settings.json` 中配置：

```json
{
  "skillsPaths": ["./skills"],
  "agentsPaths": ["./agents"],
  "memory": {
    "files": ["./AGENTS.md"]
  }
}
```

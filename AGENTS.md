# AGENTS.md - CUG-Hydro-Skills 项目指南

CUG-Hydro 研究组的 LLM Skills 共享仓库，用于管理和开发 Claude Code 的技能、代理和规则。

## 项目结构

```
CUG-Hydro-Skills/
├── .claude/           # Claude Code 配置
├── skills/            # 技能定义
├── agents/            # 代理定义
├── rules/             # 编码规则（common/, julia/）
├── examples/          # 示例代码
└── config/            # LLM API 配置
```

## 构建/运行/测试命令

### 技能测试

```bash
# Lean 模式（默认）
bash skills/repomix-gh/src/repomix-gh.sh owner/repo

# 指定输出文件
bash skills/repomix-gh/src/repomix-gh.sh owner/repo output.md

# 强制刷新缓存
bash skills/repomix-gh/src/repomix-gh.sh owner/repo test.md --force

# Full 模式（包含所有文件）
bash skills/repomix-gh/src/repomix-gh.sh owner/repo output.md --full
```

### Julia 示例运行

```bash
julia examples/fft_demo.jl
julia examples/monte_carlo_pi.jl
julia examples/hook-demo/example_simulation.jl
```

### 依赖检查

```bash
which gh repomix           # 检查依赖
npm install -g repomix     # 安装 repomix
```

## 代码风格指南

### 核心原则：Linux 极简主义

- **Do one thing well**：每个模块只做好一件事
- 避免冗余变量和过度抽象
- 行宽 ≤100 字符
- 避免深层嵌套（>3 层需重构）
- 早返回（early return）模式

### Markdown 文档（技能/代理定义）

```markdown
---
name: skill-name
argument-hint: <required> [optional] [--flag]
description: 简短描述
tools: ["Read", "Grep", "Glob", "Bash"]  # 仅代理需要
---
```

标题层级：`#` 主标题 → `##` 章节 → `###` 子章节 → `>` 提示
代码块使用语言标识符：`bash`, `julia`, `json`, `powershell`

### Bash 脚本

```bash
#!/usr/bin/env bash
# 脚本名称 - 一行描述

CACHE_DIR="$HOME/.cache/script-name"  # 变量大写，声明在顶部

while [[ $# -gt 0 ]]; do
    case $1 in
        --force)  FORCE=1; shift ;;
        -*)       echo "未知选项: $1"; exit 1 ;;
        *)        [[ -z "$REPO" ]] && REPO="$1" || OUT="$1"; shift ;;
    esac
done
# 使用 [[ ]] 条件判断，$() 替代反引号
```

### Julia 代码

```julia
function process(data::Vector{Float64}, params::Dict)
    n = length(data)
    result = zeros(n)  # 预分配
    n == 0 && return result  # 早返回
    
    for i in 2:n
        result[i] = data[i] - data[i-1]
    end
    return result
end

# 向量化优先
estimate_pi(n) = 4 * sum(@. rand(n)^2 + rand(n)^2 ≤ 1) / n

using Random
Random.seed!(42)  # 确保可复现
```

### JSON 配置

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit && tool_input.file_path matches \"\\.jl$\"",
      "hooks": [{ "type": "command", "command": "echo '检查'" }],
      "description": "Julia代码修改后检查"
    }]
  }
}
```

### 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 文件（技能/代理） | kebab-case | `code-reviewer.md` |
| 目录 | kebab-case | `repomix-gh/` |
| Julia 函数 | snake_case | `estimate_pi()` |
| Bash 变量 | UPPER_CASE | `CACHE_DIR` |
| JSON 键 | camelCase | `tool_input` |

### 错误处理

```bash
# Bash
command -v gh >/dev/null || { echo "需要 gh"; exit 1; }
[[ -f "$FILE" ]] && echo "存在" || echo "不存在"
```

```julia
# Julia: 显式检查
denominator = params["fc"] - soil[i]
runoff[i] = denominator > 0 ? soil[i] / denominator * params["k"] : 0.0
```

## 代理审查清单

- [ ] 是否专精一事（Do one thing well）
- [ ] 是否有冗余变量/抽象
- [ ] 是否避免深层嵌套（>3 层需重构）
- [ ] 行宽是否 ≤100 字符
- [ ] 排版是否美观统一
- [ ] 是否早返回
- [ ] 错误处理是否明确

## 可复现性要求

- Julia: 使用 `Project.toml` 和 `Manifest.toml` 锁定依赖
- 随机过程必须设置种子：`Random.seed!(42)`
- 原始数据永不修改，使用脚本处理
- 数据目录：`data/raw/`（只读）→ `data/processed/`

## 科研伦理

- 不伪造、篡改数据
- 异常值处理必须透明说明
- 引用必须亲自阅读原文
- AI 辅助需明确披露

## Hooks 配置示例

```json
{
  "PostToolUse": [{
    "matcher": "Edit && tool_input.file_path matches \"\\.jl$\"",
    "hooks": [{
      "type": "agent",
      "prompt": "按照 agents/code-reviewer.md 审查文件",
      "timeout": 60
    }]
  }]
}
```

## 常用命令速查

```bash
mklink /J ".claude\skills" "%CD%\skills"  # Windows 创建软链接
cat .claude/settings.json                   # 检查配置
claude agent code-reviewer --files file.jl  # 运行审查代理
```

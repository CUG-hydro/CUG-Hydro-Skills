#!/bin/bash
#
# PreToolUse hook: Linux极简主义原则提醒
# 在 Edit 或 Write 操作前提醒遵循极简主义

# 从stdin读取JSON输入（虽然这里不需要解析，但消耗掉输入）
cat > /dev/null

MSG=$(cat << 'EOF'
┌─────────────────────────────────────────────────────────────┐
│  Linux极简主义原则提醒                                        │
├─────────────────────────────────────────────────────────────┤
│  • 只做一件事，并把它做好 (Do one thing and do it well)       │
│  • 如无必要，勿增实体 (Keep it simple, stupid)               │
│  • 小即是美 (Small is beautiful)                            │
│  • 组合优于集成 (Composition over integration)               │
│  • 文本流是通用接口 (Text streams are the universal interface) │
│  • 避免过度工程 (Avoid over-engineering)                     │
│  • 代码即文档，注释应说明"为什么"而非"是什么"                 │
└─────────────────────────────────────────────────────────────┘

- 符合代码排版规范、排版美观；
- 注意代码的易读性，不能为了单纯的追求简洁，让代码变得深奥难懂。
EOF
)

jq -n --arg msg "$MSG" '{systemMessage: $msg}'

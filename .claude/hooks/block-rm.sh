#!/bin/bash
# .claude/hooks/block-rm.sh

# 1. 读取所有输入到变量
INPUT=$(cat)

# 2. 导出到文件（格式化后的 JSON）
echo "$INPUT" | jq . > input.json



# 3. 提取命令
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

if echo "$COMMAND" | grep -q 'rm -rf'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Destructive command blocked by hook"
    }
  }'
else
  exit 0  # allow the command
fi

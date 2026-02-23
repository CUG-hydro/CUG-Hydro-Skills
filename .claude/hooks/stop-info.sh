#!/bin/bash
# Stop hook：显示当前模型和时间

# 读取 SessionStart 保存的 model 信息
if [ -f log/session-info.json ]; then
  MODEL=$(jq -r '.model // "unknown"' log/session-info.json)
else
  MODEL="unknown"
fi

# 当前时间
TIME=$(date '+%Y-%m-%d %H:%M:%S')

# 返回 systemMessage 显示在对话中
echo "{
  \"systemMessage\": \"[$TIME] Model: $MODEL\"
}"

exit 0

#!/bin/bash
# 记录会话信息（model 等）
INPUT=$(cat)
EVENT_NAME=$(echo "$INPUT" | jq -r '.hook_event_name // "unknown"')

# 根据事件类型提取不同字段
if [ "$EVENT_NAME" = "ConfigChange" ]; then
  # ConfigChange 事件
  SOURCE=$(echo "$INPUT" | jq -r '.source // "unknown"')
  FILE_PATH=$(echo "$INPUT" | jq -r '.file_path // "unknown"')
  SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')

  # 追加到日志
  echo "$INPUT" >> log.txt

  # 更新 session-info.json（保留原有 model 信息，添加配置变更记录）
  if [ -f log/session-info.json ]; then
    OLD_MODEL=$(jq -r '.model // "unknown"' log/session-info.json)
    OLD_SESSION_ID=$(jq -r '.session_id // "unknown"' log/session-info.json)
  else
    OLD_MODEL="unknown"
    OLD_SESSION_ID="$SESSION_ID"
  fi

  cat > log/session-info.json <<EOF
{
  "model": "$OLD_MODEL",
  "session_id": "$OLD_SESSION_ID",
  "source": "$SOURCE",
  "config_change": {
    "file_path": "$FILE_PATH",
    "time": "$(date '+%Y-%m-%d %H:%M:%S')"
  }
}
EOF
else
  # SessionStart 或其他事件
  MODEL=$(echo "$INPUT" | jq -r '.model // "unknown"')
  SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
  SOURCE=$(echo "$INPUT" | jq -r '.source // "unknown"')

  echo "$INPUT" >> log.txt

  # 保存到文件
  cat > log/session-info.json <<EOF
{
  "model": "$MODEL",
  "session_id": "$SESSION_ID",
  "source": "$SOURCE",
  "start_time": "$(date '+%Y-%m-%d %H:%M:%S')"
}
EOF
fi

exit 0

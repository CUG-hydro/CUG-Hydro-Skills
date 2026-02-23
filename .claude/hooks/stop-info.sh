#!/bin/bash
# Stop hook: show model and time
MODEL=$(jq -r '.model // "unknown"' log/session-info.json 2>/dev/null || echo "unknown")
TIME=$(date '+%Y-%m-%d %H:%M:%S')
echo "{\"systemMessage\": \"[$TIME] Model: $MODEL\"}"

#!/bin/bash
# Log all Bash commands to JSONL
mkdir -p log
jq -c --arg t "$(date -Iseconds)" '{
  time: $t,
  command: .tool_input.command,
  description: .tool_input.description,
  cwd,
  tool_use_id
}' >> log/bash-history.jsonl

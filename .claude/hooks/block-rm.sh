#!/bin/bash
# Block destructive rm -rf commands
CMD=$(jq -r '.tool_input.command // empty')
[[ "$CMD" =~ ^rm\ .*-rf ]] || exit 0

jq -n '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: "rm -rf blocked"
  }
}'

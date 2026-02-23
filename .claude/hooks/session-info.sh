#!/bin/bash
# Save session info for other hooks
mkdir -p log
jq '{
  model: (.model // "unknown"),
  session_id: (.session_id // "unknown"),
  source: (.source // "unknown"),
  time: (now | strftime("%Y-%m-%d %H:%M:%S"))
}' > log/session-info.json

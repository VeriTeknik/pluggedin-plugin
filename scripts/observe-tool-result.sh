#!/bin/bash
# observe-tool-result.sh - Record tool results as observations (async)
#
# Called by Claude Code's PostToolUse hook for Bash commands.
# Records error patterns and significant results as observations.

set -euo pipefail

API_KEY="${PLUGGEDIN_API_KEY:-}"
BASE_URL="${PLUGGEDIN_API_BASE_URL:-https://plugged.in}"

if [ -z "$API_KEY" ]; then
  exit 0
fi

HOOK_STATE_DIR="${TMPDIR:-/tmp}/pluggedin-${CLAUDE_SESSION_ID:-$$}"

if [ ! -f "$HOOK_STATE_DIR/session_uuid" ]; then
  exit 0
fi

SESSION_UUID=$(cat "$HOOK_STATE_DIR/session_uuid")

# The tool result is passed via stdin from Claude Code
TOOL_RESULT=$(cat 2>/dev/null || echo "")

# Only observe if there's meaningful content (errors, etc.)
if [ ${#TOOL_RESULT} -lt 10 ]; then
  exit 0
fi

# Check if this looks like an error
OBSERVATION_TYPE="tool_result"
if echo "$TOOL_RESULT" | grep -qiE '(error|fail|exception|panic|ENOENT|EACCES|denied|refused)'; then
  OBSERVATION_TYPE="error_pattern"
fi

# Truncate to reasonable size
CONTENT=$(echo "$TOOL_RESULT" | head -c 2000)

# Escape for JSON
CONTENT_ESCAPED=$(echo "$CONTENT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))' 2>/dev/null || echo '""')

curl -s -X POST "${BASE_URL}/api/memory/sessions/${SESSION_UUID}/observations" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"observationType\": \"${OBSERVATION_TYPE}\", \"content\": ${CONTENT_ESCAPED}}" \
  2>/dev/null > /dev/null || true

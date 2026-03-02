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

# Record temporal event for synchronicity detection
if [[ -n "$TOOL_NAME" ]]; then
  curl -s -X POST "${BASE_URL}/api/memory/temporal-events" \
    -H "Authorization: Bearer ${API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{\"events\":[{\"tool_name\":\"${TOOL_NAME}\",\"event_type\":\"tool_result\",\"outcome\":\"${OUTCOME:-neutral}\"}]}" \
    --max-time 3 2>/dev/null &
fi

# If error detected, query CBP for collective knowledge about this error
if [ "$OBSERVATION_TYPE" = "error_pattern" ]; then
  ERROR_QUERY=$(echo "$CONTENT" | head -c 300)
  ERROR_QUERY_ENCODED=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.stdin.read().strip()))" <<< "$ERROR_QUERY" 2>/dev/null || echo "")

  if [ -n "$ERROR_QUERY_ENCODED" ]; then
    CBP_RESULT=$(curl -s -X GET "${BASE_URL}/api/memory/cbp?query=${ERROR_QUERY_ENCODED}&context=post_error" \
      -H "Authorization: Bearer ${API_KEY}" \
      2>/dev/null || echo "")

    # If CBP returned patterns, output them for Claude Code context injection
    if echo "$CBP_RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin); exit(0 if d.get('success') and d.get('data') else 1)" 2>/dev/null; then
      PATTERNS=$(echo "$CBP_RESULT" | python3 -c "
import json,sys
d=json.load(sys.stdin)
for p in (d.get('data') or [])[:3]:
    print(f\"[CBP] {p.get('patternType','')}: {p.get('pattern', p.get('description',''))}\")
" 2>/dev/null || echo "")

      if [ -n "$PATTERNS" ]; then
        echo "<pluggedin-cbp-suggestion>"
        echo "Collective knowledge suggests:"
        echo "$PATTERNS"
        echo "</pluggedin-cbp-suggestion>"
      fi
    fi
  fi
fi

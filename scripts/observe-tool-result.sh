#!/bin/bash
# observe-tool-result.sh - Record tool results as observations (async)
#
# Called by Claude Code's PostToolUse hook for Bash commands.
# Records error patterns and significant results as observations.
#
# Claude Code passes hook input as JSON on stdin with fields:
#   tool_name, tool_input, tool_response, tool_use_id, session_id, etc.

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

# Read hook input from stdin (Claude Code provides JSON with tool_name, tool_response, etc.)
INPUT=$(cat 2>/dev/null || echo "")

# Extract tool_name and tool_response from the hook input JSON
PARSED=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    tool_name = d.get('tool_name', '')
    # tool_response can be a string or object; serialize it
    response = d.get('tool_response', '')
    if isinstance(response, dict):
        response = json.dumps(response)
    elif not isinstance(response, str):
        response = str(response)
    # Output tab-delimited: tool_name\ttool_response
    # Ensure no tabs in tool_name
    tool_name = tool_name.replace('\t', ' ')
    print(f'{tool_name}\t{response}')
except Exception:
    print('\t')
" 2>/dev/null || echo $'\t')

IFS=$'\t' read -r TOOL_NAME TOOL_RESULT <<< "$PARSED"

# Only observe if there's meaningful content (errors, etc.)
if [ ${#TOOL_RESULT} -lt 10 ]; then
  exit 0
fi

# Check if this looks like an error
OBSERVATION_TYPE="tool_result"
OUTCOME="neutral"
if echo "$TOOL_RESULT" | grep -qiE '(error|fail|exception|panic|ENOENT|EACCES|denied|refused)'; then
  OBSERVATION_TYPE="error_pattern"
  OUTCOME="failure"
fi

# Truncate to reasonable size and build JSON payload safely
OBSERVATION_PAYLOAD=$(echo "$TOOL_RESULT" | head -c 2000 | python3 -c "
import json, sys
content = sys.stdin.read()
print(json.dumps({'observationType': sys.argv[1], 'content': content}))
" "$OBSERVATION_TYPE" 2>/dev/null || echo "")

if [ -n "$OBSERVATION_PAYLOAD" ]; then
  curl -s -X POST "${BASE_URL}/api/memory/sessions/${SESSION_UUID}/observations" \
    -H "Authorization: Bearer ${API_KEY}" \
    -H "Content-Type: application/json" \
    -d "$OBSERVATION_PAYLOAD" \
    2>/dev/null > /dev/null || true
fi

# Record temporal event for synchronicity detection
if [[ -n "$TOOL_NAME" ]]; then
  TEMPORAL_PAYLOAD=$(python3 -c "
import json, sys
print(json.dumps({'events': [{'tool_name': sys.argv[1], 'event_type': 'tool_result', 'outcome': sys.argv[2]}]}))
" "$TOOL_NAME" "$OUTCOME" 2>/dev/null || echo "")

  if [[ -n "$TEMPORAL_PAYLOAD" ]]; then
    curl -s -X POST "${BASE_URL}/api/memory/temporal-events" \
      -H "Authorization: Bearer ${API_KEY}" \
      -H "Content-Type: application/json" \
      -d "$TEMPORAL_PAYLOAD" \
      --max-time 3 >/dev/null 2>&1 &
  fi
fi

# If error detected, query CBP for collective knowledge about this error
if [ "$OBSERVATION_TYPE" = "error_pattern" ]; then
  ERROR_QUERY=$(echo "$TOOL_RESULT" | head -c 300)
  ERROR_QUERY_ENCODED=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.stdin.read().strip()))" <<< "$ERROR_QUERY" 2>/dev/null || echo "")

  if [ -n "$ERROR_QUERY_ENCODED" ]; then
    CBP_RESULT=$(curl -s -X GET "${BASE_URL}/api/memory/cbp?query=${ERROR_QUERY_ENCODED}&context=post_error" \
      -H "Authorization: Bearer ${API_KEY}" \
      2>/dev/null || echo "")

    # If CBP returned patterns, sanitize and output for Claude Code context injection
    if [ -n "$CBP_RESULT" ]; then
      PATTERNS=$(echo "$CBP_RESULT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    if not d.get('success') or not d.get('data'):
        sys.exit(0)
    for p in (d.get('data') or [])[:3]:
        ptype = str(p.get('patternType', '')).replace('<', '').replace('>', '')
        desc = str(p.get('pattern', p.get('description', ''))).replace('<', '').replace('>', '')
        print(f'[CBP] {ptype}: {desc}')
except Exception:
    pass
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

#!/bin/bash
# session-start.sh - Start a Plugged.in memory session on SessionStart
#
# Called by Claude Code's SessionStart hook. Outputs context that gets
# injected into the conversation as a system message.

set -euo pipefail

# Read hook input JSON from stdin (Claude Code passes context this way)
HOOK_INPUT=$(cat)
CLAUDE_SESSION_ID=$(echo "$HOOK_INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id',''))" 2>/dev/null)
: "${CLAUDE_SESSION_ID:=unknown}"

# Load credentials (env var → ~/.config/pluggedin/credentials.json)
source "$(dirname "$0")/load-credentials.sh"

if [ -z "$API_KEY" ]; then
  echo "Plugged.in memory: No API key configured. Run /pluggedin:setup to configure."
  exit 0
fi

# Start a memory session via the API
RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "${BASE_URL}/api/memory/sessions" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"content_session_id\": \"claude-code-${CLAUDE_SESSION_ID}\"}" \
  2>/dev/null || echo -e "\n000")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
  SESSION_UUID=$(echo "$BODY" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('data',{}).get('uuid',''))" 2>/dev/null)
  MEMORY_SESSION_ID=$(echo "$BODY" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('data',{}).get('memorySessionId',''))" 2>/dev/null)

  if [ -n "$SESSION_UUID" ]; then
    # Store session info for other hooks to use
    HOOK_STATE_DIR="${TMPDIR:-/tmp}/pluggedin-${CLAUDE_SESSION_ID:-$$}"
    mkdir -p "$HOOK_STATE_DIR"
    echo "$SESSION_UUID" > "$HOOK_STATE_DIR/session_uuid"
    echo "$MEMORY_SESSION_ID" > "$HOOK_STATE_DIR/memory_session_id"

    # Fetch individuation score
    INDIVIDUATION=$(curl -s "${BASE_URL}/api/memory/individuation" \
      -H "Authorization: Bearer ${API_KEY}" \
      --max-time 3 2>/dev/null || true)

    # Parse all individuation fields in a single python3 call (tab-delimited)
    INDIV_VALUES=$(echo "$INDIVIDUATION" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin).get('data', {})
except Exception:
    data = {}
total = str(data.get('total', 0))
level = str(data.get('level', 'nascent'))
tip = str(data.get('tip', ''))
# Sanitize: strip angle brackets and tabs to prevent tag/delimiter injection
for ch in ('<', '>', '\t', '\r', '\n'):
    level = level.replace(ch, '')
    tip = tip.replace(ch, ' ')
    total = total.replace(ch, '')
print(f'{total}\t{level}\t{tip}')
" 2>/dev/null || true)

    if [ -z "$INDIV_VALUES" ]; then
      INDIV_TOTAL="0"
      INDIV_LEVEL="nascent"
      INDIV_TIP=""
    else
      IFS=$'\t' read -r INDIV_TOTAL INDIV_LEVEL INDIV_TIP <<< "$INDIV_VALUES"
      : "${INDIV_TOTAL:=0}"
      : "${INDIV_LEVEL:=nascent}"
      : "${INDIV_TIP:=}"
    fi

    echo "<pluggedin-memory-session>"
    echo "Memory session started (${MEMORY_SESSION_ID})."
    echo "Use pluggedin_memory_observe to record important observations during this session."
    echo "The session will auto-close with a Z-report when you finish."
    if [ "$INDIV_TOTAL" != "0" ]; then
      echo ""
      echo "Individuation: ${INDIV_LEVEL} (score: ${INDIV_TOTAL})"
      if [ -n "$INDIV_TIP" ]; then
        echo "Tip: ${INDIV_TIP}"
      fi
    fi
    echo "</pluggedin-memory-session>"
  fi
else
  echo "Plugged.in memory: Could not start session (HTTP ${HTTP_CODE}). Memory features will be unavailable."
fi

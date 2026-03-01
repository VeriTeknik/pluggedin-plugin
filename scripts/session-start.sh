#!/bin/bash
# session-start.sh - Start a Plugged.in memory session on SessionStart
#
# Called by Claude Code's SessionStart hook. Outputs context that gets
# injected into the conversation as a system message.

set -euo pipefail

API_KEY="${PLUGGEDIN_API_KEY:-}"
BASE_URL="${PLUGGEDIN_API_BASE_URL:-https://plugged.in}"

if [ -z "$API_KEY" ]; then
  echo "Plugged.in memory: No API key configured. Run /pluggedin:setup to configure."
  exit 0
fi

# Start a memory session via the API
RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "${BASE_URL}/api/memory/sessions" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"contentSessionId\": \"claude-code-${CLAUDE_SESSION_ID:-unknown}\"}" \
  2>/dev/null || echo -e "\n000")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
  SESSION_UUID=$(echo "$BODY" | grep -o '"uuid":"[^"]*"' | head -1 | cut -d'"' -f4)
  MEMORY_SESSION_ID=$(echo "$BODY" | grep -o '"memorySessionId":"[^"]*"' | head -1 | cut -d'"' -f4)

  if [ -n "$SESSION_UUID" ]; then
    # Store session info for other hooks to use
    HOOK_STATE_DIR="${TMPDIR:-/tmp}/pluggedin-${CLAUDE_SESSION_ID:-$$}"
    mkdir -p "$HOOK_STATE_DIR"
    echo "$SESSION_UUID" > "$HOOK_STATE_DIR/session_uuid"
    echo "$MEMORY_SESSION_ID" > "$HOOK_STATE_DIR/memory_session_id"

    echo "<pluggedin-memory-session>"
    echo "Memory session started (${MEMORY_SESSION_ID})."
    echo "Use pluggedin_memory_observe to record important observations during this session."
    echo "The session will auto-close with a Z-report when you finish."
    echo "</pluggedin-memory-session>"
  fi
else
  echo "Plugged.in memory: Could not start session (HTTP ${HTTP_CODE}). Memory features will be unavailable."
fi

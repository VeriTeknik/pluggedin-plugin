#!/bin/bash
# session-end.sh - End the Plugged.in memory session and trigger Z-report
#
# Called by Claude Code's Stop hook. Ends the active session and
# triggers Z-report generation for session continuity.

set -euo pipefail

# Read hook input JSON from stdin (Claude Code passes context this way)
HOOK_INPUT=$(cat)
CLAUDE_SESSION_ID=$(echo "$HOOK_INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id',''))" 2>/dev/null)
: "${CLAUDE_SESSION_ID:=$$}"

# Load credentials (env var → ~/.config/pluggedin/credentials.json)
source "$(dirname "$0")/load-credentials.sh"

if [ -z "$API_KEY" ]; then
  exit 0
fi

HOOK_STATE_DIR="${TMPDIR:-/tmp}/pluggedin-${CLAUDE_SESSION_ID}"

if [ ! -f "$HOOK_STATE_DIR/memory_session_id" ]; then
  exit 0
fi

MEMORY_SESSION_ID=$(cat "$HOOK_STATE_DIR/memory_session_id")
SESSION_UUID=$(cat "$HOOK_STATE_DIR/session_uuid")

# End the session (triggers Z-report generation)
RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X PATCH "${BASE_URL}/api/memory/sessions/${SESSION_UUID}" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"status": "completed"}' \
  2>/dev/null || echo -e "\n000")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" = "200" ]; then
  # Trigger Z-report generation
  curl -s -X POST "${BASE_URL}/api/memory/sessions/${SESSION_UUID}/z-report" \
    -H "Authorization: Bearer ${API_KEY}" \
    -H "Content-Type: application/json" \
    2>/dev/null > /dev/null || true

  echo "Memory session ${MEMORY_SESSION_ID} ended. Z-report generation triggered."
fi

# Cleanup state files
rm -rf "$HOOK_STATE_DIR" 2>/dev/null || true

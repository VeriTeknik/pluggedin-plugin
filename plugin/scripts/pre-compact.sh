#!/bin/bash
# pre-compact.sh - Inject relevant memories before context compaction
#
# Called by Claude Code's PreCompact hook. Searches for memories relevant
# to the current conversation and injects them so they survive compaction.

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

if [ ! -f "$HOOK_STATE_DIR/session_uuid" ]; then
  exit 0
fi

# Search for memories related to the current working directory / project
PROJECT_NAME=$(basename "$(pwd)")

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "${BASE_URL}/api/memory/search" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"${PROJECT_NAME} development session context\", \"topK\": 5}" \
  2>/dev/null || echo -e "\n000")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
  # Check if there are results
  RESULT_COUNT=$(echo "$BODY" | grep -o '"uuid"' | wc -l | tr -d ' ')

  if [ "$RESULT_COUNT" -gt 0 ]; then
    echo "<pluggedin-memory-context>"
    echo "Relevant memories retrieved before compaction (${RESULT_COUNT} results):"
    echo "$BODY"
    echo "</pluggedin-memory-context>"
  fi
fi

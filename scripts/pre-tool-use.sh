#!/usr/bin/env bash
# Pre-Tool-Use Hook: Inject archetype-routed collective patterns before tool execution
set -euo pipefail

PLUGGEDIN_API_KEY="${PLUGGEDIN_API_KEY:-}"
BASE_URL="${PLUGGEDIN_API_BASE_URL:-https://plugged.in}"

if [[ -z "$PLUGGEDIN_API_KEY" ]]; then exit 0; fi

# Read tool name from stdin (Claude Code hook provides tool_name)
TOOL_NAME="${TOOL_NAME:-}"
if [[ -z "$TOOL_NAME" ]]; then exit 0; fi

# Query archetype-enhanced patterns
RESPONSE=$(curl -s -X POST "${BASE_URL}/api/memory/archetype/inject" \
  -H "Authorization: Bearer ${PLUGGEDIN_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"tool_name\":\"${TOOL_NAME}\",\"observation_type\":\"tool_call\"}" \
  --max-time 3 2>/dev/null || true)

if [[ -z "$RESPONSE" ]]; then exit 0; fi

PATTERN_COUNT=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(len(d.get('patterns',[])))" 2>/dev/null || echo "0")

if [[ "$PATTERN_COUNT" -gt 0 ]]; then
  PATTERNS=$(echo "$RESPONSE" | python3 -c "
import sys, json
d = json.load(sys.stdin)
for p in d.get('patterns', []):
    label = p.get('archetypeLabel', 'Sage Advice')
    desc = p.get('description', '')[:200]
    conf = int(p.get('confidence', 0) * 100)
    print(f'[{label}] {desc} ({conf}% confidence)')
" 2>/dev/null || true)

  if [[ -n "$PATTERNS" ]]; then
    echo "<collective-intelligence>"
    echo "$PATTERNS"
    echo "</collective-intelligence>"
  fi
fi

#!/usr/bin/env bash
# Pre-Tool-Use Hook: Inject archetype-routed collective patterns before tool execution
#
# Claude Code passes hook input as JSON on stdin with fields:
#   tool_name, tool_input, tool_use_id, session_id, cwd, etc.
set -euo pipefail

API_KEY="${PLUGGEDIN_API_KEY:-}"
BASE_URL="${PLUGGEDIN_API_BASE_URL:-https://plugged.in}"

if [[ -z "$API_KEY" ]]; then exit 0; fi

# Read hook input from stdin (Claude Code provides JSON with tool_name)
INPUT=$(cat 2>/dev/null || echo "")
if [[ -z "$INPUT" ]]; then exit 0; fi

TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null || echo "")
if [[ -z "$TOOL_NAME" ]]; then exit 0; fi

# Build JSON payload safely (prevents injection from tool names with special chars)
JSON_PAYLOAD=$(python3 -c "import json,sys; print(json.dumps({'tool_name': sys.argv[1], 'observation_type': 'tool_call'}))" "$TOOL_NAME")

# Query archetype-enhanced patterns
RESPONSE=$(curl -s -X POST "${BASE_URL}/api/memory/archetype/inject" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD" \
  --max-time 3 2>/dev/null || true)

if [[ -z "$RESPONSE" ]]; then exit 0; fi

# Extract and sanitize patterns in a single python3 call
# Strips any characters that could break out of XML-like tags
PATTERNS=$(echo "$RESPONSE" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    patterns = d.get('patterns', [])
    if not patterns:
        sys.exit(0)
    for p in patterns:
        label = str(p.get('archetypeLabel', 'Sage Advice'))[:50]
        desc = str(p.get('description', ''))[:200]
        conf = int(p.get('confidence', 0) * 100)
        # Sanitize: strip angle brackets to prevent tag injection
        label = label.replace('<', '').replace('>', '')
        desc = desc.replace('<', '').replace('>', '')
        print(f'[{label}] {desc} ({conf}% confidence)')
except Exception:
    pass
" 2>/dev/null || true)

if [[ -n "$PATTERNS" ]]; then
  echo "<collective-intelligence>"
  echo "$PATTERNS"
  echo "</collective-intelligence>"
fi

#!/usr/bin/env bash
# Pre-Tool-Use Hook: Inject archetype-routed collective patterns before tool execution
#
# Claude Code passes hook input as JSON on stdin with fields:
#   tool_name, tool_input, tool_use_id, session_id, cwd, etc.
set -euo pipefail

# Load credentials (env var → ~/.config/pluggedin/credentials.json)
source "$(dirname "$0")/load-credentials.sh"

if [[ -z "$API_KEY" ]]; then exit 0; fi

# Read hook input from stdin (Claude Code provides JSON with tool_name)
INPUT=$(cat 2>/dev/null || echo "")
if [[ -z "$INPUT" ]]; then exit 0; fi

TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null || echo "")
if [[ -z "$TOOL_NAME" ]]; then exit 0; fi

# ── Procedure warnings for high-risk Bash commands ──────────────────────────
# Before executing risky operations, surface relevant procedures and shocks
# so Claude has the right context BEFORE acting (not only after failure).
if [[ "$TOOL_NAME" == "Bash" ]]; then
  TOOL_INPUT=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    cmd = d.get('tool_input', {}).get('command', '')
    print(cmd)
except Exception:
    pass
" 2>/dev/null || echo "")

  RISK_QUERY=""
  if echo "$TOOL_INPUT" | grep -qE 'db:migrate|alembic upgrade|drizzle-kit push'; then
    RISK_QUERY="database migration procedure safe migration path"
  elif echo "$TOOL_INPUT" | grep -qE 'git push|push --force|push -f'; then
    RISK_QUERY="git push production deploy procedure"
  elif echo "$TOOL_INPUT" | grep -qE 'rm -rf|rmdir.*-r|find.*-delete'; then
    RISK_QUERY="destructive delete file removal procedure"
  elif echo "$TOOL_INPUT" | grep -qE 'kubectl delete|kubectl apply|helm uninstall|helm upgrade'; then
    RISK_QUERY="kubernetes deployment procedure"
  elif echo "$TOOL_INPUT" | grep -qE 'docker rm|docker rmi|docker system prune'; then
    RISK_QUERY="docker cleanup procedure"
  fi

  if [[ -n "$RISK_QUERY" ]]; then
    ENCODED_QUERY=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$RISK_QUERY")
    RISK_RESPONSE=$(curl -s \
      "${BASE_URL}/api/memory/resume?query=${ENCODED_QUERY}&top_procedures=2&top_longterm=2" \
      -H "Authorization: Bearer ${API_KEY}" \
      --max-time 3 2>/dev/null || true)

    RISK_BRIEF=$(echo "$RISK_RESPONSE" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    data = d.get('data', {})
    procs = data.get('procedures', [])
    shocks = data.get('shocks', [])
    lines = []
    for p in procs:
        content = str(p.get('content', ''))[:200].replace('\n', ' ')
        # Sanitize: strip angle brackets to prevent tag injection
        content = content.replace('<', '[').replace('>', ']')
        if content:
            lines.append(f'[Procedure] {content}')
    for s in shocks:
        content = str(s.get('content', ''))[:200].replace('\n', ' ')
        content = content.replace('<', '[').replace('>', ']')
        if content:
            lines.append(f'WARNING [Shock] {content}')
    if lines:
        print('\n'.join(lines))
except Exception:
    pass
" 2>/dev/null || true)

    if [[ -n "$RISK_BRIEF" ]]; then
      echo "<pluggedin-procedure-warning>"
      echo "$RISK_BRIEF"
      echo "</pluggedin-procedure-warning>"
    fi
  fi
fi

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

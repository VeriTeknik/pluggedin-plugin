#!/bin/bash
# load-credentials.sh - Resolve Plugged.in API credentials
#
# Sources API_KEY and BASE_URL from (in priority order):
# 1. Environment variables (PLUGGEDIN_API_KEY, PLUGGEDIN_API_BASE_URL)
# 2. $XDG_CONFIG_HOME/pluggedin/credentials.json (default: ~/.config)
#
# Usage: source this file from any hook script
#   source "$(dirname "$0")/load-credentials.sh"

API_KEY="${PLUGGEDIN_API_KEY:-}"
BASE_URL="${PLUGGEDIN_API_BASE_URL:-}"

# If env var is missing, try XDG credentials file
if [ -z "$API_KEY" ]; then
  CRED_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/pluggedin/credentials.json"
  if [ -f "$CRED_FILE" ]; then
    _CRED=$(python3 -c "
import json, sys
try:
    d = json.load(open(sys.argv[1]))
    print(d.get('api_key', '') + '\t' + d.get('base_url', ''))
except Exception:
    print('\t')
" "$CRED_FILE" 2>/dev/null || echo $'\t')
    IFS=$'\t' read -r API_KEY _BASE_URL <<< "$_CRED"
    if [ -z "$BASE_URL" ] && [ -n "$_BASE_URL" ]; then
      BASE_URL="$_BASE_URL"
    fi
    unset _CRED _BASE_URL
  fi
fi

# Default base URL
: "${BASE_URL:=https://plugged.in}"

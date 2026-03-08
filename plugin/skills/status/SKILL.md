---
name: status
description: "Check Plugged.in connection status, active session, and memory statistics"
user-invocable: true
---

# Plugged.in Status

Check the current connection status and memory statistics.

## Process

1. Check if `PLUGGEDIN_API_KEY` is configured (env var or `~/.config/pluggedin/credentials.json`)
2. Call `pluggedin_discover_tools` to verify the MCP connection
3. Check for an active memory session
4. Display memory statistics if available

Report the following:
- **Connection**: Connected / Not configured / Error
- **API Key**: Configured (masked) / Not set
- **Credentials Location**: `~/.config/pluggedin/credentials.json` or environment variable
- **Active Session**: Session ID and observation count, or "No active session"
- **Memory Stats**: Total memories by ring type, fresh observations pending
- **Available Tools**: Count of static + dynamic tools

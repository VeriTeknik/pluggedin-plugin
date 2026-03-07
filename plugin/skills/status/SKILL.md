---
name: status
description: "Check Plugged.in connection status, active session, and memory statistics"
user-invokable: true
---

# Plugged.in Status

Check the current connection status and memory statistics.

## Process

1. Check if `PLUGGEDIN_API_KEY` is configured
2. Call `pluggedin_discover_tools` to verify the MCP connection
3. Check for an active memory session
4. Display memory statistics if available

Report the following:
- **Connection**: Connected / Not configured / Error
- **API Key**: Configured (masked) / Not set
- **Active Session**: Session ID and observation count, or "No active session"
- **Memory Stats**: Total memories by ring type, fresh observations pending
- **Available Tools**: Count of static + dynamic tools

---
name: memory-status
description: "Show memory system status including active session, ring counts, and recent observations"
user-invokable: true
---

# Memory Status

Display the current state of the Plugged.in memory system.

## Process

1. Check for active memory session
2. Fetch memory statistics from the API
3. Display a summary including:

### Session Info
- Active session UUID and start time
- Observation count for current session
- Focus items in working set

### Memory Ring Counts
- **Procedures**: How-to guides and workflows
- **Practice**: Habits and conventions
- **Long-term**: Validated insights
- **Shocks**: Critical events

### Fresh Memory
- Unclassified observations pending analytics
- Oldest unprocessed observation age

### Decay Status
- Memories at each decay stage (full, compressed, summary, essence)
- Next scheduled decay run

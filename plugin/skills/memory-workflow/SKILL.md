---
name: memory-workflow
description: "Guide the memory session lifecycle - start sessions, record observations, search memories, and end sessions with Z-reports. Use when working with Plugged.in memory system."
user-invocable: true
argument-hint: "[start|end|status]"
---

# Memory Workflow

Manage the Plugged.in memory session lifecycle.

## Session Lifecycle

1. **Start Session**: Call `pluggedin_memory_session_start` at the beginning of work
2. **Observe**: During work, call `pluggedin_memory_observe` to record:
   - `tool_call` / `tool_result`: Tool usage and outcomes
   - `user_preference`: Explicit user preferences
   - `error_pattern`: Errors and their resolutions
   - `success_pattern`: What worked well
   - `decision`: Key decisions made
   - `insight`: Conclusions worth remembering
3. **Search**: Use `pluggedin_memory_search` to find relevant past memories (returns lightweight summaries)
4. **Details**: Use `pluggedin_memory_details` for full content of specific memories
5. **End Session**: Call `pluggedin_memory_session_end` to generate a Z-report

## Arguments

- `$ARGUMENTS` = "start": Start a new memory session
- `$ARGUMENTS` = "end": End the current session with Z-report
- `$ARGUMENTS` = "status": Show current session status

## What to Observe

Record observations for anything that would be useful in future sessions:
- Error patterns and their solutions
- User preferences about workflow, tools, or coding style
- Successful approaches to recurring problems
- Key architectural decisions and their rationale
- Tool configurations that worked

## Progressive Disclosure

Memory search uses a 3-layer system for token efficiency:
1. **Search** (Layer 1): Returns summaries (50-150 tokens each)
2. **Timeline** (Layer 2): Adds temporal context
3. **Details** (Layer 3): Returns full content

Always start with search. Only request details for memories you actually need.

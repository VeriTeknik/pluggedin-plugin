---
name: memory-extraction
description: "Smart observation capture - automatically identify and record important patterns, decisions, and insights during work. Use proactively during development sessions."
user-invokable: false
---

# Memory Extraction

Automatically identify and record important observations during a development session.

## When to Extract

Record an observation when you encounter:

### Error Patterns
- A command fails with a specific error
- A build breaks due to a dependency issue
- A test fails with an unexpected result
- An API returns an error response

Format: `[ERROR] <tool/command>: <error message> → <resolution>`

### Success Patterns
- A debugging approach that worked
- A configuration that resolved an issue
- A workflow that was particularly efficient

Format: `[SUCCESS] <what worked> in context of <what was being done>`

### User Preferences
- The user explicitly states a preference ("always use...", "never do...")
- The user corrects your approach, indicating a preference
- The user chooses between alternatives

Format: `[PREFERENCE] <preference description>`

### Decisions
- Architectural choices (library selection, pattern choice)
- Configuration decisions (environment setup, tool config)
- Workflow decisions (branching strategy, testing approach)

Format: `[DECISION] <decision> because <rationale>`

### Insights
- Patterns you notice in the codebase
- Relationships between components
- Performance characteristics

Format: `[INSIGHT] <observation>`

## How to Record

Call `pluggedin_memory_observe` with:
- `sessionUuid`: Current session UUID
- `observationType`: One of `error_pattern`, `success_pattern`, `user_preference`, `decision`, `insight`, `tool_call`, `tool_result`, `workflow_step`
- `content`: The observation text
- `outcome`: "success", "failure", or "neutral"
- `metadata`: Optional JSON with tool names, error codes, etc.

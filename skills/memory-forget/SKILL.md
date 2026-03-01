---
name: memory-forget
description: "Delete specific memories or clear memory categories. Use with caution - forgotten memories cannot be recovered."
user-invocable: true
argument-hint: "<memory-uuid or 'search query'>"
---

# Memory Forget

Remove specific memories from the Plugged.in memory system.

## Process

1. If `$ARGUMENTS` looks like a UUID, confirm deletion of that specific memory
2. If `$ARGUMENTS` is a search query, search for matching memories and present them
3. Ask for confirmation before deleting (memories cannot be recovered)
4. Delete confirmed memories via the API

## Safety

- Always confirm before deletion
- Show the memory content before deleting so the user knows what will be removed
- Suggest alternatives: decay stage can be manually set to "forgotten" instead of hard delete
- SHOCK memories require explicit confirmation as they bypass normal decay

## Note

Deleted memories are permanently removed from both the database and the vector index. The natural decay system (full -> compressed -> summary -> essence -> forgotten) is usually preferred over manual deletion.

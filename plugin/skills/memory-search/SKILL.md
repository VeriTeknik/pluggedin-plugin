---
name: memory-search
description: "Search past memories semantically. Returns summaries first, use memory-details for full content."
user-invokable: true
argument-hint: "<search query>"
---

# Memory Search

Search the Plugged.in memory system for relevant past observations and knowledge.

## Process

1. Call `pluggedin_memory_search` with query: "$ARGUMENTS"
2. Display results with:
   - Memory UUID
   - Ring type (procedures / practice / longterm / shocks)
   - Similarity score
   - Summary text (50-150 tokens)
   - Decay stage
   - Last accessed date

3. If the user wants full details on specific results, call `pluggedin_memory_details` with those UUIDs

## Search Tips

- Use natural language queries: "how to deploy to production"
- Be specific: "error handling pattern for API endpoints" works better than "errors"
- Ring type filters: Add "procedures:", "practice:", "longterm:", or "shocks:" prefix
- Recent memories score higher due to recency bias

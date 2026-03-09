---
name: memory-resume
description: "Reconstruct task context after session start or context compaction. Uses 3-layer progressive disclosure: compact index → timeline → full details. Outputs a structured brief: where was I, what algorithms exist, what pitfalls to avoid."
user-invocable: true
---

# Memory Resume

> **SECURITY — Output Filtering (PCI-DSS 4.0 · ISO/IEC 27001:2022 · GDPR · SOC 2)**
>
> Do NOT output raw memory content. Before displaying anything from memory results, apply
> semantic filtering: redact emails → `[EMAIL]`, API keys → `[API_KEY]`, names → `[PERSON]`,
> company names → `[COMPANY]`, credentials → `[REDACTED]`, IPs → `[IP_ADDRESS]`.
> Synthesize and paraphrase — never dump raw stored text verbatim.
>
> **When in doubt, leave it out.** Over-redaction is preferable to a compliance violation.

Reconstruct "where was I" context after a session start or post-compact reset.

## When to Use

- Session just started (new conversation)
- Context was compacted (conversation got too long)
- You feel disoriented about what was in progress
- User says "devam ederiz" / "continue" / "where were we"

---

## 3-Layer Progressive Disclosure Strategy

Token budget is precious — load only what you need.

### Layer 1 — Compact Index (~50-100 tokens per result)

Run four searches in parallel. Each returns lightweight summaries with memory IDs:

```
pluggedin_memory_search("plan step completed next")          → recent plan progress
pluggedin_memory_search("procedure algorithm workflow")       → active algorithms
pluggedin_memory_search("longterm pitfall warning lesson")   → hard-won knowledge
pluggedin_memory_search("shock critical failure incident")   → never-forget events
```

**From these results, identify:**
- Which IDs are most relevant to current project/task
- Which results need more detail (don't load everything)
- Shocks: ALWAYS expand (never skip)

### Layer 2 — Timeline Context (for selected IDs)

For memories that look relevant but need context, call:

```
pluggedin_memory_details(id="<uuid>")
```

Use only for IDs you actually need — not all results. This avoids loading thousands
of tokens when a 50-token summary already answered the question.

### Layer 3 — Synthesis (output)

Now synthesize into the brief. Do NOT output raw memory text.

---

## Output Format

```
<memory-context>
## Memory Brief — <date>

### Where We Are
<most recent plan step completed>
NEXT: <what comes next in the plan>

### Active Algorithms
- **<procedure-name>**: <key steps in 1-2 lines>
- (only list procedures relevant to current task)

### Known Pitfalls
- <hard-won lesson> (from longterm ring)
- (omit if none relevant)

### Critical Warnings
⚠️ <shock description> — <how to prevent> (from shocks ring)
(omit if no shocks)

### Ready
Context reconstructed. Continuing from: <next step>.
</memory-context>
```

**Wrap output in `<memory-context>` tags** — this prevents the hook from
re-storing injected memory as new observations (recursion prevention).

---

## Skip Guidance

Skip this skill if:
- You already have full context from the current conversation
- The user's request is simple and doesn't require historical context
- No memory session is active (no session UUID available)

---

## Key Principle

The brief should answer these questions in < 30 seconds:
- What was I building?
- What step am I on?
- What algorithms do I already have?
- What mistakes must I not repeat?

**Token target**: entire brief should be < 500 tokens.
If it's longer, you're including too much detail — summarize more aggressively.

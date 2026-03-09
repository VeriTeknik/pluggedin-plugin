---
name: memory-capture-plan-step
description: "Record completion of a step from a written implementation plan into fresh memory. Use after marking a plan item done — maintains task continuity across context compaction."
user-invocable: true
---

# Memory Capture — Plan Step

> **SECURITY — Two-Layer Defence (PCI-DSS 4.0 · ISO/IEC 27001:2022 · GDPR · SOC 2)**
>
> **Layer 1 (automatic):** The hook script pipes all content through `pci-scrub.py` before
> sending to the API. Catches: emails, API keys (OpenAI/Anthropic/AWS/GitHub/…), IPv4/IPv6,
> credit card numbers, national IDs (US SSN, UK NI, EU VAT, Aadhaar, …), connection string
> credentials, home paths, phone numbers.
>
> **Layer 2 (YOU):** Regex cannot catch everything. Before calling any memory tool, apply
> semantic judgment. Do NOT record:
> - Person names, usernames, employee IDs → replace with `[PERSON]`
> - Company / customer names → `[COMPANY]`
> - Passwords, MFA codes, session tokens, cookies → `[REDACTED]`
> - Health / medical data (HIPAA PHI) → `[REDACTED]`
> - Financial account numbers, balances → `[REDACTED]`
> - Precise location data (GPS, home address) → `[ADDRESS]`
> - Anything business-confidential (pricing, contracts) → `[REDACTED]`
>
> **When in doubt, leave it out.** Over-redaction is always preferable to a compliance violation.

Record plan step completion to maintain continuity across context resets.

## When to Use

- A numbered item in a written implementation plan was just completed
- A phase / week milestone was reached
- You are about to mark a checklist item as done

## What to Capture

```
PLAN: <plan name / file>
STEP: <step number and title>
STATUS: completed

WHAT WAS DONE:
<concise description of exactly what was implemented>

DEVIATIONS FROM PLAN:
<any differences from the original plan spec, or "none">

NEXT STEP:
<what comes next in the plan>

BLOCKERS/NOTES:
<anything the next session needs to know, or "none">
```

## How to Record

1. Build the observation text above
2. Scrub PII before recording
3. Call `pluggedin_memory_observe` with:
   - `sessionUuid`: current session UUID
   - `observationType`: `workflow_step`
   - `content`: the structured text
   - `outcome`: `"success"`
   - `metadata`: `{"ring": "fresh", "plan_step": "<step number>", "plan_name": "<name>"}`

## Why This Matters

After context compaction, running `memory-resume` will surface recent plan steps.
This is what lets a new session know "Step 3 is done, Step 4 is next" without
re-reading the entire plan from scratch.

## Example

```
PLAN: memory-system-overhaul (2026-03-09)
STEP: Phase 1, Week 1 — PCI Scrubber
STATUS: completed

WHAT WAS DONE:
Created pci-scrub.py in pluggedin-plugin/plugin/scripts/.
Covers: emails, API keys, credit cards, tax IDs, IPs, home paths, phones.
Updated observe-tool-result.sh to pipe through scrubber before sending to API.

DEVIATIONS FROM PLAN:
None — implemented exactly as designed in Design Section 1.

NEXT STEP:
Phase 1, Week 1 — 6 Trigger Skills (memory-capture-solution, etc.)

BLOCKERS/NOTES:
none
```

---

## Skip Guidance

Skip this skill if:
- The information is already obvious from the current conversation context
- The content contains personal names, customer data, or business-confidential information that cannot be fully redacted
- The observation is trivial (e.g., ran `ls`, checked a file, viewed a README)
- A `<private>` block wraps the relevant content — respect user opt-out

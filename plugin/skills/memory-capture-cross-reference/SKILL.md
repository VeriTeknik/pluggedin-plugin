---
name: memory-capture-cross-reference
description: "Record a cross-reference when new functionality touches an existing system — ensures future work on the existing system considers the new dependency. Use after adding X to Y."
user-invocable: true
---

# Memory Capture — Cross Reference

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

Record architectural cross-references so future work doesn't miss dependencies.

## When to Use

- Added feature X to existing system Y → future Y changes must consider X
- New service depends on an existing service in a non-obvious way
- Added a required step to an existing procedure (amendment)
- Created a file that must be updated whenever another file changes

## What to Capture

```
CROSS-REFERENCE: <new thing> → <existing thing>

RELATIONSHIP:
<new thing> was added to <existing thing>. Future changes to <existing thing>
must also update <new thing> because: <reason>.

TRIGGER CONDITION:
When someone works on <existing thing>, they should:
- <action 1>
- <action 2>

FILES:
- New: <file path>
- Existing: <file path>

RELATED PROCEDURE:
<procedure name if this amends an existing algorithm, or "none">
```

## How to Record

1. Build the cross-reference text above
2. Scrub PII before recording
3. Call `pluggedin_memory_observe` with:
   - `sessionUuid`: current session UUID
   - `observationType`: `insight`
   - `content`: the structured text
   - `outcome`: `"neutral"`
   - `metadata`: `{"ring": "procedures", "xref_from": "<new>", "xref_to": "<existing>"}`

## Example

```
CROSS-REFERENCE: central-logging → all lib/ service functions

RELATIONSHIP:
Central logging (lib/logger.ts) was added. Future changes to any service
function in lib/ must also add logger.info/logger.error calls because:
all service operations must be observable in production logs.

TRIGGER CONDITION:
When someone creates a new function in lib/:
- Import logger: import { logger } from '@/lib/logger'
- Wrap the main operation with logger.info/error
- Do NOT use console.log in lib/ files

FILES:
- New: lib/logger.ts
- Existing: lib/*.ts (all service files)

RELATED PROCEDURE:
central-logging-setup v1.0
```

---

## Skip Guidance

Skip this skill if:
- The information is already obvious from the current conversation context
- The content contains personal names, customer data, or business-confidential information that cannot be fully redacted
- The observation is trivial (e.g., ran `ls`, checked a file, viewed a README)
- A `<private>` block wraps the relevant content — respect user opt-out

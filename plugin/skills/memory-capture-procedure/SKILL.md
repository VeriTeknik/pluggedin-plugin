---
name: memory-capture-procedure
description: "Capture a numbered implementation algorithm into procedures memory after completing a feature end-to-end. Use when a new feature/system was built — records the exact steps so the next similar build starts from this algorithm."
user-invocable: true
---

# Memory Capture — Procedure

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

Capture a reusable implementation algorithm into procedures ring memory.

## When to Use

- New feature implemented end-to-end (PR merged / push to main)
- New service / integration set up from scratch
- Complex migration or deployment completed
- Multi-step workflow established that will be repeated

## What to Capture

Structure as a numbered algorithm with branches:

```
PROCEDURE: <name> (v1.0)
DOMAIN: <e.g., database-migration, auth-setup, api-integration>

ALGORITHM:
1. <first step>
   - Sub-step a
   - Sub-step b
   ERROR: if X → do Y
2. <second step>
3. <third step>
   BRANCH: if condition A → go to step 5
           if condition B → go to step 4
4. ...
N. VERIFY: <how to confirm the procedure succeeded>

KNOWN PITFALLS:
- <thing that goes wrong and how to avoid it>

CROSS-REFERENCES:
- Related to procedure: <other-procedure-name>
- Files changed: <list key files>
```

## How to Record

1. Write out the full numbered algorithm
2. Scrub PII: replace emails, API keys, paths with [REDACTED] tokens
3. **Cross-reference check** — before recording, search for similar existing procedures:
   ```
   pluggedin_memory_search("<procedure domain> procedure algorithm")
   ```
   - If similarity > 0.8 with an existing procedure: **amend it** (add a new version note)
     rather than creating a duplicate. Use `pluggedin_memory_details` to fetch the full text
     of the similar procedure, then record the amended version.
   - If no close match: record as a new procedure (step 4 below).
4. Call `pluggedin_memory_observe` with:
   - `sessionUuid`: current session UUID
   - `observationType`: `workflow_step`
   - `content`: the full procedure text
   - `outcome`: `"success"`
   - `metadata`: `{"ring": "procedures", "procedure_name": "<name>", "version": "1.0"}`

## Auto-Trigger Condition

This skill fires automatically when a git push to main / PR merge is detected,
or when the user marks a plan step as the final step.

## Example

```
PROCEDURE: central-logging-setup (v1.0)
DOMAIN: observability

ALGORITHM:
1. Install logger package: pnpm add winston
2. Create lib/logger.ts with LoggerService class
   - Configure transports: Console (dev), File (prod)
   - Export singleton instance
3. Update all existing service files:
   - Import logger from lib/logger
   - Replace console.log → logger.info
   - Replace console.error → logger.error
   ERROR: if file uses 'use client' → skip (client components can't use Node logger)
4. Add request logging middleware to app/api/ routes
5. VERIFY: pnpm build passes, logs appear in /var/log/app/

KNOWN PITFALLS:
- winston is not Edge-runtime compatible — exclude from middleware bundle
- File transport needs write permission on /var/log/app/

CROSS-REFERENCES:
- Any new service function added to lib/ must call logger per this procedure
```

---

## Skip Guidance

Skip this skill if:
- The information is already obvious from the current conversation context
- The content contains personal names, customer data, or business-confidential information that cannot be fully redacted
- The observation is trivial (e.g., ran `ls`, checked a file, viewed a README)
- A `<private>` block wraps the relevant content — respect user opt-out

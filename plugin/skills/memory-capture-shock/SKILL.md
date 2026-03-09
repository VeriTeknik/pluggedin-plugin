---
name: memory-capture-shock
description: "Record a critical failure — data loss, production incident, security breach, or cascade failure — into permanent shock memory. Shocks never decay and are always surfaced in memory-resume briefs."
user-invocable: true
---

# Memory Capture — Shock

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

**CRITICAL IMPORTANCE: Shocks are permanent. They never decay. They are always
surfaced in memory-resume briefs. Use this ring for incidents that must never
be forgotten — even years later.**

## When to Use

- Data was deleted or corrupted (intentional or accidental)
- Production went down
- A security breach or credential exposure occurred
- A cascade failure took down multiple systems
- An irreversible action was taken by mistake

Do NOT use for ordinary bugs or recoverable errors — those go to `longterm`.

## What to Capture

```
SHOCK: <short name, e.g., "prod-db-truncate-2026-03">
SEVERITY: critical | high
DATE: <YYYY-MM-DD>

WHAT HAPPENED:
<exact description of what failed and how>

BLAST RADIUS:
<what was affected: data, users, systems, duration>

ROOT CAUSE:
<why it happened>

HOW TO DETECT:
<early warning signs, monitoring alerts that would catch this>

HOW TO PREVENT:
<exact guard rails: checks, flags, confirmations required before the action>

RECOVERY:
<how it was recovered from, or "not recoverable">
```

## How to Record

1. Build the shock text above — be specific and factual
2. Scrub PII before recording
3. Call `pluggedin_memory_observe` with:
   - `sessionUuid`: current session UUID
   - `observationType`: `failure_pattern`
   - `content`: the full shock text
   - `outcome`: `"failure"`
   - `metadata`: `{"ring": "shocks", "severity": "critical", "shock_name": "<name>"}`

## Auto-Trigger Condition

This skill fires automatically when critical failure keywords are detected:
- "data loss", "dropped table", "deleted production", "breach", "credential exposed"
- "cascade failure", "service down", "rollback failed", "irreversible"

## Example

```
SHOCK: accidental-db-migrate-direct-2026-01
SEVERITY: critical
DATE: 2026-01-15

WHAT HAPPENED:
Applied Drizzle migration directly with raw SQL ALTER TABLE on prod database
instead of using pnpm db:migrate. Foreign key constraint dropped silently.
Downstream queries started failing 20 minutes later.

BLAST RADIUS:
~200 API requests failed over 45 minutes. No data loss but
3 tables had inconsistent FK state requiring manual repair.

ROOT CAUSE:
Bypassed pnpm db:migrate workflow to "save time". Direct SQL has no
rollback trail and no idempotency check.

HOW TO DETECT:
DB query errors on FK-constrained tables after schema change.
Monitor: constraint_violations metric in pg_stat_user_tables.

HOW TO PREVENT:
ALWAYS use pnpm db:generate then pnpm db:migrate.
NEVER run raw ALTER TABLE on prod.
Add pre-commit hook that rejects .sql files in migration runs.

RECOVERY:
Manual FK reconstruction from schema.ts definitions.
Full process took 2 hours.
```

---

## Skip Guidance

Skip this skill if:
- The information is already obvious from the current conversation context
- The content contains personal names, customer data, or business-confidential information that cannot be fully redacted
- The observation is trivial (e.g., ran `ls`, checked a file, viewed a README)
- A `<private>` block wraps the relevant content — respect user opt-out

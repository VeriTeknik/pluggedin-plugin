---
name: memory-capture-solution
description: "Capture a hard-won solution into long-term memory after trial-and-error resolution. Use when a problem was solved after ≥1 failed attempts — records what failed, what worked, and why."
user-invocable: true
---

# Memory Capture — Solution

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

Capture a hard-won solution into long-term memory so it is never re-discovered.

## When to Use

- A bug was fixed after ≥1 failed attempts
- A configuration issue was resolved by trial and error
- An API / library behavior was discovered through experimentation
- A framework constraint was worked around

Do NOT use for trivial fixes that were obvious on first attempt.

## What to Capture

Structure the observation as follows (fill in all sections):

```
PROBLEM: <1-2 sentences describing the symptom / error>

FAILED APPROACHES:
- <approach 1> → why it failed
- <approach 2> → why it failed

SOLUTION: <exact steps / code / config that fixed it>

WHY IT WORKS: <root cause explanation>

CONTEXT: <framework version, env, any relevant constraints>
```

## How to Record

1. Build the observation text using the structure above
2. Scrub PII: replace emails, API keys, IPs, paths with [REDACTED] tokens
3. Call `pluggedin_memory_observe` with:
   - `sessionUuid`: current session UUID (from session state)
   - `observationType`: `success_pattern`
   - `content`: the structured text above
   - `outcome`: `"success"`
   - `metadata`: `{"ring": "longterm", "tags": ["solution", "<domain>"]}`

## Auto-Trigger Condition

This skill fires automatically when:
- `error_pattern` observation was recorded in this session AND
- A subsequent `success_pattern` resolves the same tool/domain

## Example

```
PROBLEM: Next.js 15 middleware throws "Cannot use import statement" at runtime

FAILED APPROACHES:
- Added "type": "module" to package.json → broke API routes
- Used require() syntax → TypeScript compilation error

SOLUTION: Use next.config.js `experimental.serverComponentsExternalPackages`
to exclude the problematic package from middleware bundling.

WHY IT WORKS: Next.js middleware runs in Edge runtime which has different
module resolution than Node.js. Excluding packages forces CommonJS fallback.

CONTEXT: Next.js 15.1.0, package: @some/lib@2.0.0
```

---

## Skip Guidance

Skip this skill if:
- The information is already obvious from the current conversation context
- The content contains personal names, customer data, or business-confidential information that cannot be fully redacted
- The observation is trivial (e.g., ran `ls`, checked a file, viewed a README)
- A `<private>` block wraps the relevant content — respect user opt-out

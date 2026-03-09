# Security Preamble — Memory Capture Skills

> This preamble is included in every memory-capture skill.
> It defines the two-layer defence model for sensitive data.

---

## Two-Layer Defence

### Layer 1 — Deterministic (pci-scrub.py)
The hook script automatically pipes all content through `pci-scrub.py` before sending to the API.
This catches known patterns by regex: emails, API keys, IPs, national IDs, card numbers, etc.

### Layer 2 — Semantic (YOU, the LLM)
Regex cannot catch everything. Before calling any memory tool, YOU must apply judgment.

**Do not record anything that:**
- Identifies a specific person (name, username, employee ID, biometric reference)
- Could be used to authenticate or impersonate (passwords, MFA codes, session tokens, cookies)
- Reveals business-confidential data (customer names, contract values, internal pricing)
- Contains health or medical information (HIPAA PHI)
- Constitutes financial data beyond what is strictly necessary (account numbers, balances)
- Includes location data precise enough to identify an individual (GPS coords, home address)

**Replace with neutral tokens:**
- Person names → `[PERSON]`
- Company/customer names → `[COMPANY]`
- Addresses → `[ADDRESS]`
- Confidential values → `[REDACTED]`

---

## Applicable Standards

| Standard | Requirement |
|----------|-------------|
| **PCI-DSS 4.0** | Never store PANs, CVVs, PINs, or track data in any system not in scope |
| **ISO/IEC 27001:2022 A.8.11** | Personal data must be minimized — collect only what is necessary |
| **GDPR Art. 5(1)(c)** | Data minimisation — adequate, relevant, limited to what is necessary |
| **GDPR Art. 5(1)(f)** | Integrity and confidentiality — protect against unauthorised processing |
| **SOC 2 Type II CC6.1** | Restrict logical access to sensitive data |
| **HIPAA § 164.502(b)** | Minimum necessary standard for PHI |
| **NIST SP 800-53 AC-3** | Access enforcement — enforce approved authorizations |

---

## Quick Decision Rule

> **When in doubt, leave it out.**
>
> If you cannot determine whether something is sensitive, treat it as sensitive and redact it.
> An over-redacted memory observation is always preferable to a compliance violation.

---

## What IS safe to record

- Technical patterns: error messages (scrubbed), stack traces (scrubbed), config keys (not values)
- Architectural decisions: "use X library instead of Y because Z"
- Procedural steps: numbered algorithms, commands, file paths relative to project root
- Outcome summaries: "migration succeeded", "test passed", "build failed at step N"

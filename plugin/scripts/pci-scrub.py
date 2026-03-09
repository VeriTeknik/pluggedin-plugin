#!/usr/bin/env python3
"""
Security Scrubber — strips PII and sensitive data before memory storage.

Standards: PCI-DSS 4.0 · ISO/IEC 27001:2022 · GDPR Art.5(1)(f) · SOC 2 Type II

Two-layer defence:
  Layer 1 (this file): deterministic regex for known patterns
  Layer 2 (skill preamble): LLM semantic judgement for unknown/contextual data

Usage (pipe mode):
    echo "some text" | python3 pci-scrub.py

Usage (argument mode):
    python3 pci-scrub.py "some text to scrub"

Returns scrubbed text on stdout. Never fails — on any error returns original input.
"""

import re
import sys

# ---------------------------------------------------------------------------
# Patterns ordered most-specific → least-specific to avoid partial matches.
# Rule of thumb: if in doubt, redact.
# ---------------------------------------------------------------------------
_RULES = [

    # ── Well-known AI / cloud provider API keys ───────────────────────────
    # These prefixes are published by the providers themselves.
    (re.compile(
        r'(?:'
        r'sk-ant-[A-Za-z0-9\-_]{20,}'          # Anthropic (Claude)
        r'|sk-proj-[A-Za-z0-9\-_]{20,}'         # OpenAI project keys
        r'|sk-[A-Za-z0-9]{20,}'                 # OpenAI legacy
        r'|xai-[A-Za-z0-9\-_]{20,}'             # xAI (Grok)
        r'|AIza[0-9A-Za-z\-_]{35}'              # Google AI / Firebase
        r'|ya29\.[0-9A-Za-z\-_]{20,}'           # Google OAuth access tokens
        r'|AKIA[0-9A-Z]{16}'                    # AWS access key ID
        r'|gh[ps]_[A-Za-z0-9]{36,}'             # GitHub personal / server tokens
        r'|github_pat_[A-Za-z0-9_]{82}'         # GitHub fine-grained PAT
        r'|glpat-[0-9A-Za-z\-_]{20}'            # GitLab PAT
        r'|npm_[A-Za-z0-9]{36,}'                # npm tokens
        r'|SG\.[A-Za-z0-9\-_]{22}\.[A-Za-z0-9\-_]{43}'  # SendGrid
        r'|xoxb-[0-9\-A-Za-z]{50,}'             # Slack bot token
        r'|xoxp-[0-9\-A-Za-z]{70,}'             # Slack user token
        r'|xoxa-[0-9\-A-Za-z]{50,}'             # Slack workspace token
        r'|pk_(?:live|test)_[A-Za-z0-9]{20,}'   # Stripe public key
        r'|sk_(?:live|test)_[A-Za-z0-9]{20,}'   # Stripe secret key
        r'|pg_in_[A-Za-z0-9_\-]{10,}'           # Plugged.in API keys
        r')'
    ), '[API_KEY]'),

    # ── Generic auth headers / long opaque tokens ─────────────────────────
    (re.compile(
        r'(?:'
        r'(?:Bearer|Token|Authorization)\s+[A-Za-z0-9\-_.~+/=]{20,}'
        r'|[A-Za-z0-9+/=]{40,}(?=["\'\s,}\]])'  # long base64 blobs
        r')'
    ), '[AUTH_TOKEN]'),

    # ── Connection string credentials ─────────────────────────────────────
    # postgres://user:PASSWORD@host  mongodb://user:PASS@host
    (re.compile(
        r'(?<=://)[^:@\s]+:[^@\s]+(?=@)',
        re.IGNORECASE
    ), '[USER]:[PASSWORD]'),

    # ── Email addresses (GDPR personal data) ─────────────────────────────
    (re.compile(
        r'\b[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}\b'
    ), '[EMAIL]'),

    # ── Credit / debit card numbers (PCI-DSS PAN) ─────────────────────────
    # Matches 16-digit groups with optional spaces/dashes
    (re.compile(
        r'\b(?:\d{4}[\s\-]?){3}\d{4}\b'
    ), '[CARD_NUMBER]'),

    # ── IPv6 addresses ─────────────────────────────────────────────────────
    # Deliberately simple: ≥2 colon-separated hex groups (0-4 hex digits each).
    # Catches all common forms (full, compressed, loopback, IPv4-mapped).
    # Minor false-positive risk (e.g. CSS vars) is acceptable in a scrubber.
    (re.compile(
        r'(?:[0-9a-fA-F]{0,4}:){2,7}[0-9a-fA-F]{0,4}'
    ), '[IP_ADDRESS]'),

    # ── IPv4 addresses ─────────────────────────────────────────────────────
    (re.compile(
        r'\b(?:\d{1,3}\.){3}\d{1,3}\b'
    ), '[IP_ADDRESS]'),

    # ── National / government IDs (ISO-27001 A.8 personal data) ───────────
    (re.compile(
        r'(?:'
        r'\b\d{3}[-\s]\d{2}[-\s]\d{4}\b'           # US SSN: 123-45-6789
        r'|\b[A-Z]{2}[\s]?\d{2}[\s]?\d{2}[\s]?\d{2}[\s]?[A-Z]\b'  # UK NI
        r'|\b[A-Z]{5}\d{4}[A-Z]\b'                  # Indian PAN
        r'|\b\d{4}[\s]\d{4}[\s]\d{4}\b'             # Indian Aadhaar
        r'|(?<!\d)\d{9,12}(?!\d)'                   # Generic 9-12 digit ID (TR, DE, FR…)
        r')'
    ), '[NATIONAL_ID]'),

    # ── Home / user directory paths ────────────────────────────────────────
    (re.compile(
        r'(?:/home/|/Users/)[^/\s"\']+/'
    ), '/home/[USER]/'),

    # ── Phone numbers (GDPR, various formats) ─────────────────────────────
    (re.compile(
        r'(?:\+\d{1,3}[\s\-]?)?(?:\(?\d{3}\)?[\s\-]?)\d{3}[\s\-]?\d{2}[\s\-]?\d{2}'
    ), '[PHONE]'),

]


def scrub(text: str) -> str:
    """Apply all security rules to text, return cleaned version."""
    for pattern, replacement in _RULES:
        text = pattern.sub(replacement, text)
    return text


def main() -> None:
    if len(sys.argv) > 1:
        raw = ' '.join(sys.argv[1:])
    else:
        raw = sys.stdin.read()

    try:
        result = scrub(raw)
    except Exception:
        result = raw  # Never fail — return original on any error

    sys.stdout.write(result)


if __name__ == '__main__':
    main()

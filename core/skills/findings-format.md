# Findings Format

All security and audit findings must use this format. Consistent structure enables automated processing and trend analysis.

---

## Single Finding

```markdown
### [SEVERITY] [SHORT-ID] — [Title]

**Severity:** CRITICAL | HIGH | MEDIUM | LOW | INFO
**CVSS Score:** [0.0–10.0] (if applicable)
**Category:** [injection | auth | access-control | exposure | config | dependency | crypto | infra]
**Status:** OPEN | ESCALATED | ACKNOWLEDGED | RESOLVED

**Location:**
- File: [path/to/file.ext]
- Line: [line number or range]
- Component: [function, endpoint, or service name]

**Description:**
[2-3 sentences: what the vulnerability is and why it exists]

**Impact:**
[What an attacker could achieve if this is exploited]

**Evidence:**
```[language]
[Minimal code snippet or config showing the issue]
```

**Recommendation:**
[Specific, actionable fix — not "sanitize input" but exactly how]

**References:**
- [CVE or CWE number if applicable]
- [Link to relevant documentation]
```

---

## Severity Definitions

| Severity | CVSS Range | Meaning |
|---|---|---|
| CRITICAL | 9.0–10.0 | Remote code execution, full auth bypass, data breach risk |
| HIGH | 7.0–8.9 | Significant impact, likely exploitable — escalate immediately |
| MEDIUM | 4.0–6.9 | Real risk, harder to exploit or limited impact |
| LOW | 0.1–3.9 | Minor risk, requires unusual conditions |
| INFO | 0.0 | Observation, best practice, or hardening opportunity |

---

## Findings File Header

```markdown
# Security Findings: [scope]
**Date:** YYYY-MM-DD
**Audited by:** security-auditor
**Scope:** [what was reviewed]
**Out of scope:** [what was explicitly excluded]
**Total findings:** [N] (CRITICAL: N | HIGH: N | MEDIUM: N | LOW: N | INFO: N)

---
```

---

## Escalation Trigger

Any finding with CVSS ≥ 7.0 must trigger immediate escalation per `core/skills/escalation-rules.md`.
Do not continue the audit until the escalation is acknowledged.

---
name: security-audit
description: Conducts structured security reviews of codebases, configurations, and infrastructure. Use when performing a full security audit, reviewing code for common vulnerability classes, or auditing IaC and dependency manifests. Escalates findings with CVSS ≥ 7.0 immediately. Don't use for live penetration testing, exploit development, or routine code reviews unrelated to security (use code-review for that).
---

# Security Audit Methodology

## Pre-Audit

1. Confirm scope — what is in and out of scope.
2. Confirm finding destination — where the findings file will be saved.
3. Confirm escalation threshold — default is CVSS ≥ 7.0.
4. Open the findings file with the header below filled in before starting.
5. Do a quick architecture pass before diving into code — understand the attack surface first.

## Phase 1: Attack Surface Mapping

Identify all entry points before analysing any single one:
- Public-facing endpoints (HTTP, WebSocket, gRPC)
- Authentication boundaries
- File upload or user-supplied input handlers
- Third-party integrations and outbound calls
- Scheduled jobs and background workers
- Admin or internal interfaces

## Phase 2: Static Analysis

Review code for vulnerability classes in priority order:

1. **Authentication & authorisation** — can users access things they shouldn't?
2. **Input handling** — is all user input validated at system boundaries?
3. **Injection** — SQL, command, template, LDAP, XPath
4. **Secrets & sensitive data** — hardcoded credentials, PII in logs, insecure storage
5. **Dependencies** — known CVEs, unpinned versions
6. **Cryptography** — weak algorithms, broken key management, TLS config
7. **Error handling** — stack traces exposed, verbose errors in production
8. **Insecure defaults** — open CORS, default credentials, unnecessary permissions

## Phase 3: Configuration Review

- Infrastructure as code (Terraform, Kubernetes manifests, Dockerfiles)
- IAM policies and roles
- Network policies and firewall rules
- Environment variable handling and secret injection
- Logging configuration — what is logged, what is not

## Phase 4: Dependency Audit

- Run dependency vulnerability scanner if available.
- Check for unpinned or wildcard versions.
- Flag abandoned or unmaintained packages.

## Recording Findings

Document every finding immediately using this template:

```
### [SEVERITY] [SHORT-ID] — [Title]

**Severity:** CRITICAL | HIGH | MEDIUM | LOW | INFO
**CVSS Score:** [0.0–10.0]
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
[Minimal code snippet or config showing the issue]

**Recommendation:**
[Specific, actionable fix]

**References:**
- [CVE or CWE if applicable]
```

When uncertain: document as a potential finding with reasoning — never silence it.

**If CVSS ≥ 7.0 is found:** stop, document, escalate per `core/skills/escalation-rules.md`. Do not continue until acknowledged.

Never attempt to exploit — document the path an attacker would take, then stop.

## Severity Reference

| Severity | CVSS | Meaning |
|---|---|---|
| CRITICAL | 9.0–10.0 | RCE, full auth bypass, data breach risk |
| HIGH | 7.0–8.9 | Significant impact, likely exploitable — escalate immediately |
| MEDIUM | 4.0–6.9 | Real risk, harder to exploit or limited impact |
| LOW | 0.1–3.9 | Minor risk, requires unusual conditions |
| INFO | 0.0 | Observation, best practice, hardening opportunity |

## Post-Audit

1. Complete the findings file — every finding filled in, header counts accurate.
2. Write a one-paragraph executive summary at the top.
3. List action items in priority order (CRITICAL → HIGH → MEDIUM → LOW → INFO).
4. Save to the agreed location before responding.

## Findings File Header

```
# Security Findings: [scope]
**Date:** YYYY-MM-DD
**Scope:** [what was reviewed]
**Out of scope:** [what was explicitly excluded]
**Limitations:** [tools unavailable, areas not fully covered]
**Total findings:** [N] (CRITICAL: N | HIGH: N | MEDIUM: N | LOW: N | INFO: N)

## Executive Summary
[One paragraph: overall posture, most significant findings, recommended immediate actions]
```

## Error Handling

- If scope is ambiguous, escalate before starting — an audit with undefined scope produces unusable findings.
- If a dependency scanner is unavailable, note it explicitly under "Limitations" in the header.

# Severity Definitions

| Severity | CVSS Range | Meaning |
|---|---|---|
| CRITICAL | 9.0–10.0 | Remote code execution, full auth bypass, data breach risk |
| HIGH | 7.0–8.9 | Significant impact, likely exploitable — escalate immediately |
| MEDIUM | 4.0–6.9 | Real risk, harder to exploit or limited impact |
| LOW | 0.1–3.9 | Minor risk, requires unusual conditions |
| INFO | 0.0 | Observation, best practice, or hardening opportunity |

## Category Tags

| Tag | Covers |
|---|---|
| `injection` | SQL, command, template, LDAP, XPath injection |
| `auth` | Authentication bypass, broken session management |
| `access-control` | Authorisation failures, privilege escalation |
| `exposure` | PII in logs, sensitive data in responses, stack traces |
| `config` | Insecure defaults, open CORS, misconfigured headers |
| `dependency` | Known CVEs, unpinned versions, abandoned packages |
| `crypto` | Weak algorithms, broken key management, TLS issues |
| `infra` | IAM, network policy, Dockerfile, Kubernetes manifest issues |

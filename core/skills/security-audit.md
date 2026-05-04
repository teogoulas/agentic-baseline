# Security Audit Methodology

Use this skill when conducting any security review. Always apply `findings-format.md` for output.

---

## Pre-Audit

1. Confirm scope — what is in and out of scope
2. Confirm finding destination — where the findings file will be saved
3. Confirm escalation threshold — default is CVSS ≥ 7.0
4. Do a quick architecture pass before diving into code — understand the attack surface first

---

## Audit Phases

### Phase 1: Attack Surface Mapping

Identify all entry points before analyzing any single one:
- Public-facing endpoints (HTTP, WebSocket, gRPC)
- Authentication boundaries
- File upload or user-supplied input handlers
- Third-party integrations and outbound calls
- Scheduled jobs and background workers
- Admin or internal interfaces

### Phase 2: Static Analysis

Review code for vulnerability classes in priority order:

1. **Authentication & authorization** — can users access things they shouldn't?
2. **Input handling** — is all user input validated at system boundaries?
3. **Injection** — SQL, command, template, LDAP, XPath
4. **Secrets & sensitive data** — hardcoded credentials, PII in logs, insecure storage
5. **Dependencies** — known CVEs, unpinned versions
6. **Cryptography** — weak algorithms, broken key management, TLS config
7. **Error handling** — stack traces exposed, verbose errors in production
8. **Insecure defaults** — open CORS, default credentials, unnecessary permissions

### Phase 3: Configuration Review

- Infrastructure as code (Terraform, Kubernetes manifests, Dockerfiles)
- IAM policies and roles
- Network policies and firewall rules
- Environment variable handling and secret injection
- Logging configuration — what is logged, what is not

### Phase 4: Dependency Audit

- Run dependency vulnerability scanner if available
- Check for unpinned or wildcard versions
- Flag abandoned or unmaintained packages

---

## During Audit

- Document every finding immediately, even if low severity
- When uncertain: document as potential finding with reasoning, not silence
- If CVSS ≥ 7.0 is found: stop, document, escalate — do not continue
- Never attempt to exploit — document the path an attacker would take, stop there

---

## Post-Audit

- Write the complete findings file with the header from `findings-format.md`
- Produce a one-paragraph executive summary at the top
- List action items in priority order
- Save to agreed location before responding

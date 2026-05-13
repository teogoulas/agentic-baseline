# Default Permissions

These boundaries apply to all agents unless explicitly overridden by a project-level config.
A project-level config can only *restrict* these defaults, not expand them beyond what is listed here.

---

## Allowed Without Asking

| Action | Scope |
|---|---|
| Read any file | Entire project directory |
| Write new files | Entire project directory |
| Edit existing files | Non-config, non-auth files |
| Run tests | Any test suite |
| Install dependencies | From declared manifest files only (package.json, requirements.txt, pyproject.toml, etc.) |
| Create git branches | Feature and fix branches only |
| Create git commits | Feature and fix branches only |
| Create and remove git worktrees | For parallel agent execution only |
| Execute build commands | As defined in project scripts |
| Run Docker containers | For local sandbox testing (docker-compose.test.yml) — no production environments |
| Spawn subagents | For parallel task execution within a defined plan |
| Generate drafts | Any — always presented for review before acting |
| Read environment variables | Non-secret vars only |

---

## Requires Explicit Instruction Each Time

| Action | Why |
|---|---|
| Push to any remote | Affects shared state |
| Merge or rebase | Irreversible without force |
| Modify `.env` or secrets files | Security boundary |
| Modify CI/CD configuration | Affects all team members |
| Run database migrations | Irreversible data change |
| Delete files or directories | Destructive |
| Call external APIs | Sends data outside local environment |
| Send messages (Slack, email, etc.) | Irreversible external action |
| Install new tools or MCPs | Must go through tool-broker |

---

## Never Allowed

| Action |
|---|
| Force push to any branch |
| Drop or truncate database tables |
| Modify auth or access control configuration without explicit instruction |
| Auto-install tools or MCPs |
| Continue past a CVSS ≥ 7.0 security finding without acknowledgement |

---

## Project-Level Override

To restrict defaults for a specific project, add a `permissions.md` file at the project root:

```markdown
# Project Permissions Override
extends: core/context/permissions-default.md

## Additional Restrictions
- [e.g. "Do not modify anything in /legacy — read only"]
- [e.g. "All database queries must be reviewed before execution"]
```

Project overrides can only add restrictions. To expand permissions, update this file directly.

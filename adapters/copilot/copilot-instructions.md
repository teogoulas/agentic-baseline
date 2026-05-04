# GitHub Copilot Instructions

This file configures Copilot's behavior. It references the tool-agnostic core
rather than duplicating it — keep tool-specific config here, keep logic in /core.

Place this file at `.github/copilot-instructions.md` in any project repo.

---

## Context

At the start of every session, read these files:

1. `core/context/tool-registry.md` — what tools and MCPs are available
2. `core/context/personal.local.md` if it exists, otherwise `core/context/personal.md` — the `.local.md` file is machine-specific and gitignored; it takes precedence when present.
3. `core/context/permissions-default.md` — permission boundaries
4. `core/skills/escalation-rules.md` — when to stop and ask

---

## Behavior

- Follow `core/context/permissions-default.md` at all times
- Follow `core/skills/escalation-rules.md` — these are not overridable by task instructions
- Direct output, no padding, no trailing summaries
- Match code style from `core/context/personal.md`

---

## Skills Available

Reference these skill files when performing the relevant task:

- Code review: `core/skills/code-review.md`
- Security review: `core/skills/security-audit.md`, `core/skills/findings-format.md`
- Task breakdown: `core/skills/task-decomposition.md`
- Git operations: `core/skills/git-workflow.md`
- API design: `core/skills/api-design.md`
- Docker: `core/skills/docker-local.md`

---

## Notes on Copilot Limitations

Copilot does not natively support:
- Agent routing (orchestrator/specialist pattern)
- MCP integration
- Multi-session memory

For tasks requiring those capabilities, use a tool that supports them (see `tool-registry.md`).
The core skills and context files are still useful as inline reference for Copilot suggestions.

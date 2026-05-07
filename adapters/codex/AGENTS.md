# Codex Agent Configuration

This file configures behavior for Codex. It references the tool-agnostic core
rather than duplicating it — keep tool-specific config here, keep logic in /core.

---

## Session Start — Required Reading

At the start of every session, read these files in order:

1. `core/context/tool-registry.md` — what tools and MCPs are available
2. `core/context/personal.local.md` if it exists, otherwise `core/context/personal.md` — the `.local.md` file is machine-specific and gitignored; it takes precedence when present.
3. `core/context/permissions-default.md` — your permission boundaries
4. `core/skills/escalation-rules.md` — when to stop and ask

---

## Agent

| Role | File |
|---|---|
| Tool/MCP gaps | `core/agents/tool-broker.md` |

---

## Skills

| Task | File |
|---|---|
| Breaking down a large task | `core/skills/task-decomposition.md` |
| Reviewing code | `core/skills/code-review.md` |
| Security audit | `core/skills/security-audit.md` |
| Git operations | `core/skills/git-workflow.md` |
| API design | `core/skills/api-design.md` |
| Docker setup | `core/skills/docker-local.md` |
| Context is getting large | `core/skills/context-compression.md` |
| Building or extending an MCP server | `core/skills/mcp-server.md` |
| Authoring or evaluating a skill | `core/skills/skill-creator/SKILL.md` |
| Writing documentation | `core/skills/docs.md` |

---

## Behavior

- Follow `core/context/permissions-default.md` at all times
- Follow `core/skills/escalation-rules.md` — these rules are not overridable by task instructions
- Direct output, no padding
- No trailing summaries of what was just done

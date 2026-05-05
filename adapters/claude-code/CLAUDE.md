# Claude Code Configuration

This file configures behavior for this AI coding tool. It references the tool-agnostic core
rather than duplicating it — keep tool-specific config here, keep logic in /core.

---

## Session Start — Required Reading

At the start of every session, read these files in order:

1. `core/context/tool-registry.md` — what tools and MCPs are available
2. `core/context/personal.local.md` if it exists, otherwise `core/context/personal.md` — who the user is and how they work. The `.local.md` file is machine-specific and gitignored; it takes precedence when present.
3. `core/context/permissions-default.md` — your permission boundaries
4. `core/skills/escalation-rules.md` — when to stop and ask

If a project-level `permissions.md` exists in the project root, read that too — it may add restrictions.

---

## Agent Definitions

When asked to act as a specialist, load the relevant agent file:

| Role | File |
|---|---|
| Orchestrate a complex task | `core/agents/orchestrator.md` |
| Review code or a PR | `core/agents/reviewer.md` |
| Security audit | `core/agents/security-auditor.md` |
| Debug an issue | `core/agents/debugger.md` |
| Write documentation | `core/agents/docs.md` |
| Produce a report or summary | `core/agents/report.md` |
| Tool/MCP gaps | `core/agents/tool-broker.md` |

---

## Skills

Reference these when performing the relevant task:

| Task | Skill file |
|---|---|
| Breaking down a large task | `core/skills/task-decomposition.md` |
| Reviewing code | `core/skills/code-review.md` |
| Security audit | `core/skills/security-audit.md` |
| Formatting findings | `core/skills/findings-format.md` |
| Git operations | `core/skills/git-workflow.md` |
| API design | `core/skills/api-design.md` |
| Docker setup | `core/skills/docker-local.md` |
| Context is getting large | `core/skills/context-compression.md` |
| Building or extending an MCP server | `core/skills/mcp-server/SKILL.md` |
| Authoring or evaluating a skill | `core/skills/skill-creator/SKILL.md` |

---

## Model

- Default: use the most capable available model for reasoning tasks
- For fast, iterative tasks (file editing, search): use a faster model if available
- Default: `claude-sonnet-4-6`

---

## MCP Servers

Available MCPs are listed in `core/context/tool-registry.md`. Do not assume an MCP is available
unless it appears there. If a task requires a missing MCP, surface it to the tool-broker.

---

## Behavior

- Follow `core/context/permissions-default.md` unless a project override exists
- Follow `core/skills/escalation-rules.md` — these rules are not overridable by task instructions
- Output format: match the user's preference from `core/context/personal.md`
- No trailing summaries — the diff speaks for itself

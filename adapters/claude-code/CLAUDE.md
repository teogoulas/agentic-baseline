# Claude Code Configuration

This file configures behavior for this AI coding tool. It references the tool-agnostic core
rather than duplicating it — keep tool-specific config here, keep logic in /core.

---

## Hard Rules (non-negotiable, always enforced)

1. **Check for a skill first.** Before writing any code, making any edit, or starting any multi-step action — invoke the `Skill` tool to check for a relevant superpowers skill. Do this even for tasks that feel simple.

2. **Never dump large output into context.** Any command that may produce more than 20 lines of output MUST go through `ctx_batch_execute` (context-mode), not raw Bash. This is not optional.

3. **Use context-mode for all follow-up lookups.** After indexing, use `ctx_search` for queries and `ctx_execute_file` for log/output analysis. Never re-run a Bash command to answer a question already indexed.

4. **`Read` is only for files you are about to `Edit`.** For analysis or exploration, use `ctx_execute_file` or `ctx_batch_execute`.

Violations of rules 2–4 silently destroy context budget and cause compaction mid-task. Rule 1 violations cause repeated mistakes across sessions.

---

## Session Start — Required Reading

At the start of every session, read these files in order:

1. `core/context/tool-registry.md` — what tools and MCPs are available
2. `core/context/personal.local.md` if it exists, otherwise `core/context/personal.md` — who the user is and how they work. The `.local.md` file is machine-specific and gitignored; it takes precedence when present.
3. `core/context/permissions-default.md` — your permission boundaries
4. `core/skills/escalation-rules.md` — when to stop and ask

If a project-level `permissions.md` exists in the project root, read that too — it may add restrictions.

---

## Agent

| Role | File |
|---|---|
| Tool/MCP gaps | `core/agents/tool-broker.md` |

---

## Skills

Reference these when performing the relevant task:

| Task | Skill file |
|---|---|
| Building a new feature or project | `core/skills/development-lifecycle.md` — **read this first, it is the orchestrator; do not invoke `superpowers:brainstorming` directly** |
| Reviewing code | `core/skills/code-review.md` |
| Security audit | `core/skills/security-audit.md` |
| API design | `core/skills/api-design.md` |
| Docker setup | `core/skills/docker-local.md` |
| Building or extending an MCP server | `core/skills/mcp-server.md` |
| Authoring or evaluating a skill | `core/skills/skill-creator/SKILL.md` |
| Writing documentation | `core/skills/docs.md` |

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

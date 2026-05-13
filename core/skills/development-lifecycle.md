---
name: development-lifecycle
description: Standard 6-stage pipeline for building any feature or project — brainstorm, plan (human approval gate), parallel multi-agent execution, validate, full test suite + sandbox, ship. Explicitly invokes GSD, superpowers, and context-mode tools at each stage. Use when starting any non-trivial feature, task, or project regardless of type (web app, API, CLI, library).
---

# Development Lifecycle

Six-stage pipeline for building any feature or project. Superpowers skills are invoked explicitly at each stage — no reliance on auto-detection. GSD commands drive the lifecycle. context-mode tools manage token consumption throughout.

---

## Stage 1 — Brainstorm

Goal: crystallize the idea before committing to a plan.

```
/gsd-explore {feature or idea}
```

For ideas that benefit from visual mapping:
```
Skill("superpowers:brainstorming")
```

**Context rule:** Use `ctx_batch_execute` for all codebase exploration during brainstorm. Never dump raw file contents into context.

Outputs captured to: `.planning/notes/`, `.planning/todos/pending/`

---

## Stage 2 — Plan

Goal: produce a PLAN.md the user approves before anything executes.

```
/gsd-discuss-phase {N}
```

Before writing the plan, invoke:
```
Skill("superpowers:writing-plans")
```

Then generate:
```
/gsd-plan-phase {N}
```

**Human checkpoint — mandatory.** Stop. Present PLAN.md. Wait for explicit approval or revision instructions. Do not auto-advance to Stage 3 under any circumstance.

Outputs: `.planning/phases/{N}-{slug}/PLAN.md`

---

## Stage 3 — Execute

Goal: implement in parallel where tasks are independent, sequentially where dependencies require.

Before dispatching agents, invoke:
```
Skill("superpowers:dispatching-parallel-agents")
Skill("superpowers:using-git-worktrees")
```

Then run:
```
/gsd-execute-phase {N}
```

For complex tasks that need a spec → implement → quality-review cycle within a wave:
```
Skill("superpowers:subagent-driven-development")
```

For TDD discipline during implementation:
```
Skill("superpowers:test-driven-development")
```

For resuming after a context reset or session pause:
```
Skill("superpowers:executing-plans")
/gsd-resume-work
```

**Context rule:** Each agent has its own context window. Keep agent prompts tight — pass only what the agent needs, not the full conversation history.

---

## Stage 4 — Validate

Goal: verify the implementation matches requirements with no coverage gaps.

Run in order:

```
/gsd-validate-phase {N}
```

Fill any coverage gaps found:
```
/gsd-add-tests
```

Code review:
```
Skill("superpowers:requesting-code-review")
/gsd-code-review
```

Apply findings:
```
Skill("superpowers:receiving-code-review")
```

Security check:
```
/gsd-secure-phase {N}
```

**Context rule:** Use `ctx_execute_file` to read test output, coverage reports, and review findings. Never dump raw output into context.

**When debugging is needed:**
```
Skill("superpowers:systematic-debugging")
/gsd-debug
```

---

## Stage 5 — Test Suite + Sandbox

Goal: run the full test suite and validate the running application.

### Test suite (all project types)

Run the project test suite and enforce the coverage threshold. Fail if below minimum:

```bash
# JavaScript/TypeScript
npm test

# Python
pytest --cov

# Go
go test ./...

# Other — use project-defined test command
```

**Context rule:** Use `ctx_execute_file` to analyze test results — never dump raw output.

### Project type detection

| Signal | Test strategy |
|---|---|
| Has `docker-compose.yml` or `Dockerfile` | Sandbox eligible |
| Has `playwright.config.*` or `cypress.config.*` | E2E eligible |
| Has a server entrypoint (`main.go`, `server.py`, `index.js`) | Sandbox eligible |
| Library only (no server, no compose file) | Test runner only — skip sandbox |

### Sandbox (web apps, APIs, CLIs)

```
Read("core/skills/docker-local.md")
```

```bash
docker-compose -f docker-compose.test.yml up -d
# run e2e / smoke tests
docker-compose -f docker-compose.test.yml down
```

E2E tooling by project type:
- Web app: Playwright or Cypress
- API: supertest, httpie scripts, or curl suite
- CLI: bespoke shell scripts asserting stdout/exit codes

---

## Stage 6 — Ship

Goal: create a clean PR with all validation evidence attached.

```
Skill("superpowers:verification-before-completion")
Skill("superpowers:finishing-a-development-branch")
/gsd-ship
```

PR must include:
- Link to PLAN.md
- Validation summary (Stage 4 outcomes)
- Test coverage %
- Sandbox result (Stage 5, or "N/A — library")

---

## Cross-cutting rules

### Context management

| Situation | Action |
|---|---|
| Exploration or research | `ctx_batch_execute` — never raw Bash/Read for >20 lines |
| Analyzing output or logs | `ctx_execute_file` — never dump into context |
| Context monitor warns ≥35% | Finish current stage, do not start a new one |
| Context critical ≥25% | `/gsd-pause-work`, resume next session with `/gsd-resume-work` |

### Stage skipping

| Stage | May skip? | Condition |
|---|---|---|
| Stage 1 — Brainstorm | Yes | Requirements are already clear |
| Stage 2 — Plan | Never | Human approval is always required |
| Stage 5 — Sandbox | Yes | Library projects with no server entrypoint |

### Required plugins

This pipeline requires the following to be installed:

| Plugin | Purpose |
|---|---|
| `superpowers@claude-plugins-official` | Agent dispatch, TDD, debugging, review, git worktrees |
| `context-mode@context-mode` | Token-efficient research and output analysis |
| GSD (`get-shit-done`) | Lifecycle commands and state tracking |

Verify installation: `ls ~/.claude/plugins/installed_plugins.json` and `ls ~/.claude/skills/gsd-plan-phase`.

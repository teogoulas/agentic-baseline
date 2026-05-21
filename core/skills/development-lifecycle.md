---
name: development-lifecycle
description: Entry point for all new projects and features. Read this BEFORE invoking any other skill. Orchestrates tier routing after brainstorm — routes Tier 1 to the superpowers stack, Tier 2 to GSD phases, Tier 3 to the EDD loop. Do not invoke superpowers:brainstorming directly; this file invokes it for you.
---

# Development Lifecycle

**Read this first.** This is the orchestrator for all new projects and features. It invokes brainstorming, determines the methodology tier, then routes to the right execution path. Do not jump straight to `superpowers:brainstorming` — start here.

Six-stage pipeline applies to Tier 2 and Tier 3. Tier 1 exits after Stage 1 and follows the superpowers stack directly.

---

## Stage 1 — Brainstorm

Goal: crystallize the idea and determine the methodology tier before committing to a plan.

```
Skill("superpowers:brainstorming")
```

**Routing step — mandatory, before writing the final spec:**

Ask the user the two routing questions from `core/context/methodology-guide.md`:
1. *Is "correct" binary and fully pre-specifiable?*
2. *Will this genuinely need multiple sessions?*

Record the answer as `## Methodology Tier: [1/2/3]` in the design doc before committing the spec.

**Context rule:** Use `ctx_batch_execute` for all codebase exploration during brainstorm. Never dump raw file contents into context.

---

## Tier Routing

Immediately after Stage 1, read `## Methodology Tier` from the design doc and route:

| Tier | Condition | Action |
|---|---|---|
| **1** | Binary correctness, fits in one session | `Skill("superpowers:writing-plans")` → `Skill("superpowers:subagent-driven-development")` → `Skill("superpowers:finishing-a-development-branch")` |
| **2** | Binary correctness, genuinely multi-session | Continue to Stage 2 (GSD flow) |
| **3** | Fuzzy correctness or iterative | `Skill("edd-loop")` — edd-loop wraps Stages 2–4 per iteration |

If `## Methodology Tier` is not present in the design doc: ask the user before proceeding.

**Tier 1 exits here.** Do not proceed to Stage 2 for Tier 1 projects.

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

**Tier 3 note:** TDD runs exactly as in Tier 1/2. `edd-loop.md` measures the metric after
`gsd-validate-phase` passes — no change to the TDD cycle itself.

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

**Tier 3 note:** After validation passes, return to `edd-loop.md` Step 6 (Measure).
Do not proceed to Stage 5 until the EDD loop exits.

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

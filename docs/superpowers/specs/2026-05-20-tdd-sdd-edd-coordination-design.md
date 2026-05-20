# TDD + SDD + EDD Coordination Design

**Date:** 2026-05-20  
**Status:** Draft — pending user review  
**Tier:** Tier 3 (EDD loop applies to this project)

---

## Problem

The agentic-baseline-repo already has strong support for SDD (GSD) and a reference to TDD
(Superpowers), but no EDD layer and no mechanism for selecting or coordinating methodologies
per project. Long autonomous sessions drift without a scalar metric to anchor progress. The
three methodologies are not competing — they operate at different layers — but the framework
treats them as alternatives rather than a stack.

---

## Key Insight (from research)

| Layer | Tool | Answers |
|---|---|---|
| EDD (outermost) | EVAL.md + edd-loop skill | *What are we optimizing and are we done?* |
| SDD (middle) | GSD | *What are we building this iteration and in what scope?* |
| TDD (innermost) | Superpowers | *Is this unit correct and does it move the metric?* |

The F→P test written during TDD is not just a quality gate — it is the unit-level eval signal.
Writing the test before the code means specifying what moves the needle before touching
implementation.

SWE-RL (2502.18449) confirms: continuous reward signal significantly outperforms binary
pass/fail (34.8 vs 29.0). The eval metric should be continuous where possible, not boolean.

---

## Methodology Tiers

Three tiers selected at brainstorm time. The tier is recorded in the brainstorm design doc
under `## Methodology Tier` and read by `development-lifecycle.md` at workflow start.

| Correctness | Scope | Tier | Workflow |
|---|---|---|---|
| Binary, pre-specifiable | Small, one session | **Tier 1** | TDD only |
| Binary, pre-specifiable | Large or multi-session | **Tier 2** | TDD + SDD (existing GSD flow) |
| Fuzzy or discovered through iteration | Any | **Tier 3** | TDD + SDD + EDD loop |

**Routing questions** (asked at end of brainstorm, before scaffolding anything):

1. *Is "correct" binary and pre-specifiable — do tests cover it completely?*
2. *Is scope large enough to risk context rot across sessions?*

Tier 1 and Tier 2 require no new artifacts. Tier 3 activates the EDD loop.

---

## Enforcement Model

The workflow is hybrid — instructions where judgment is needed, scripts where reliable
computation is required.

| Concern | Implementation | Why |
|---|---|---|
| Loop logic, checkpoints, phase scoping | Markdown skills (agent reads) | Requires judgment — depth scaling, hypothesis quality, human interaction |
| Metric measurement | Shell script (`run-metric.sh`) | Must be deterministic and reproducible — agent must not reason about this |
| Stop condition evaluation | Shell script (`check-stop.sh`) | Outputs `STOP` or `CONTINUE` + reason — agent reads result, does not compute it |
| Artifact scaffolding | Shell script (`init-eval.sh`) | Ensures EVAL.md and LOOP-LOG.md are created with correct structure |
| LOOP-LOG append | Shell script (`append-loop-log.sh`) | Ensures row format is consistent across iterations |

Scripts live in `core/scripts/`. They are adapter-agnostic — any agent with shell access
invokes them via Bash. No adapter-specific code required.

The agent reads `edd-loop.md` for what to do and when. The agent invokes scripts for anything
that requires reliable output. This is the autoresearch pattern: `program.md` is the
instruction layer, the training run is the computation layer.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  EDD LAYER  (outermost)                                     │
│  EVAL.md — scalar metric, stop criteria, learnings          │
│  LOOP-LOG.md — iteration history, deltas, decisions         │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  SDD LAYER  (middle)                                  │  │
│  │  GSD — scopes, plans, and executes each phase         │  │
│  │  PLAN.md + ## EDD Context section per phase           │  │
│  │                                                       │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │  TDD LAYER  (innermost)                         │  │  │
│  │  │  Superpowers — red → green → refactor           │  │  │
│  │  │  F→P tests are the unit eval signal             │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## Workflow Skeleton (Tier 3)

### Pre-loop — runs once per project

```
1. IDEATE
   gsd-explore (if idea is vague) → superpowers:brainstorming
   Output: design doc with success criteria + ## Methodology Tier = 3

2. SCAFFOLD EVAL.md + LOOP-LOG.md
   Extract success criteria from brainstorm design doc.
   Run: bash core/scripts/init-eval.sh
   Fill in: metric name, definition, how-to-run command, target, stop criteria.
   Baseline field: TBD until first measurement.

3. MEASURE BASELINE
   Run: bash core/scripts/run-metric.sh
   Output: single numeric value → populate EVAL.md baseline field.
   If script exits non-zero → immediate human checkpoint:
     redefine metric or downgrade to Tier 2.

4. INIT LOOP-LOG row 0
   Run: bash core/scripts/append-loop-log.sh 0 "baseline" "-" "<value>" "-" "-" "-"
   Row 0 committed to LOOP-LOG.md.
```

### Per-iteration — repeats until loop exits

```
1. HYPOTHESIZE
   One sentence: "Building [X] will move [metric]
   from [current] toward [target] because [reason]."

2. SDD SCOPE — gsd-discuss-phase
   Read EVAL.md current state (metric value, stop conditions status, last learnings).
   Surface hypothesis question.
   Write ## EDD Context into phase scope.
   Scale depth to hypothesis size:
     Small  → 5-min discuss, lean PLAN.md (3–5 tasks)
     Medium → full discuss with questions, standard PLAN.md
     Large  → full discuss + spike if needed, full PLAN.md with waves

3. SDD PLAN — gsd-plan-phase
   PLAN.md includes ## EDD Context:
     hypothesis, metric_before, expected_delta, stop conditions status.
   ↓ HUMAN CHECKPOINT — approve PLAN.md before executing.

4. TDD EXECUTE — superpowers:test-driven-development + gsd-execute-phase
   Write F→P test first — this IS the unit eval signal.
   Red → Green → Refactor per unit.

5. VALIDATE — gsd-validate-phase + gsd-code-review
   All F→P tests must pass before measuring.
   Partial implementations do not produce measurements.

6. MEASURE
   Run: bash core/scripts/run-metric.sh
   Output: single numeric value (metric_after).
   delta = metric_after − metric_before.
   Run: bash core/scripts/append-loop-log.sh \
          <N> "<hypothesis>" <before> <after> <delta> "<conditions>" "TBD"
   Run: bash core/scripts/check-stop.sh
   Output: STOP <reasons> or CONTINUE.

7. STOP CHECK — output of check-stop.sh drives this step
   Script evaluates against EVAL.md stop criteria and LOOP-LOG history:
   □ Time box:            total elapsed > time_box?
   □ Target:              metric_after >= target_threshold?
   □ Diminishing returns: |delta| < delta_threshold
                          for stagnation_count consecutive iterations?
   Any condition true → script outputs STOP + which conditions triggered.

8. HUMAN CHECKPOINT
   Present:
     Metric:          [before] → [after]  (delta: +/−X%)
     Trend:           [improving / stagnant / regressing over N iterations]
     Conditions hit:  [list or "none"]
     Recommendation:  [continue / stop + reason]
   Human decides → continue or exit.
   Decision recorded in LOOP-LOG.md "Decision" column.

9. UPDATE EVAL.md (if continuing)
   metric_current = metric_after.
   Learnings: what this iteration revealed.
   Revised target or thresholds if warranted.
   → set next hypothesis → back to step 1.
```

### Post-loop — runs once on exit

```
gsd-ship                  standard shipping flow
gsd-extract-learnings     capture what the loop taught you
Archive LOOP-LOG.md   →   .planning/loop-logs/YYYY-MM-DD-[slug].md
Final EVAL.md update:     metric_final, exit_reason, date_closed
```

---

## Artifacts

### EVAL.md — `.planning/EVAL.md`

Project-scoped. Created once after brainstorm. Human-owned. Has two zones:

| Zone | Set when | Updated when |
|---|---|---|
| Static | After brainstorm | Only if goal fundamentally changes |
| Dynamic | After each iteration | Every iteration |

```markdown
# EVAL — [Project/Feature Name]

## Metric
**Name:**        [what you're measuring]
**Definition:**  [precise calculation — reproducible by anyone]
**Unit:**        [%, ms, score, count, …]
**Direction:**   [higher is better / lower is better]
**How to run:**  [shell command — must be directly executable]

## Baseline
**Value:**    [populated after first run]
**Date:**     [date measured]
**Context:**  [codebase state when measured]

## Target
**Value:**      [what "done" looks like]
**Rationale:**  [why this target]

## Stop Criteria
**Time box:**         [total elapsed limit — e.g. 2 weeks]
**Target threshold:** [metric value that counts as reached]
**Delta threshold:**  [minimum meaningful improvement — e.g. 2%]
**Stagnation count:** [consecutive iterations below threshold — e.g. 2]

## Current State
**Value:**        [updated each iteration]
**Iteration:**    [N]
**Trend:**        [improving / stagnant / regressing]
**Last updated:** [date]

## Learnings
[Human updates between iterations — what worked, revised hypotheses, pivots]
```

### LOOP-LOG.md — `.planning/LOOP-LOG.md`

Append-only during loop. Archived post-loop.

```markdown
# Loop Log — [Project/Feature Name]

| # | Hypothesis | Before | After | Delta | Conditions hit | Decision | Date |
|---|---|---|---|---|---|---|---|
| 0 | baseline | — | [value] | — | — | — | [date] |
| 1 | Building X will move M because Y | [v] | [v] | +2.3% | none | continue | [date] |
```

### PLAN.md — EDD Context section (extension, Tier 3 only)

Appended to standard GSD PLAN.md format:

```markdown
## EDD Context
**Hypothesis:**    Building [X] will move [metric] from [current] toward [target] because [reason]
**Metric before:** [value from LOOP-LOG latest row]
**Expected delta:** [+/− X%]
**Stop conditions status:**
  - Time box:            [elapsed] / [limit]
  - Target:              [current] / [target]
  - Diminishing returns: [N] consecutive below threshold / [stagnation_count]
```

---

## Integration Points

### What changes in existing tools

**`core/skills/development-lifecycle.md`**
- Add tier routing step after brainstorm (reads `## Methodology Tier` from design doc)
- Tier 1 → TDD only; Tier 2 → existing flow unchanged; Tier 3 → edd-loop wraps stages 2–4

**`gsd-discuss-phase`** (called by edd-loop, not modified directly)
- edd-loop injects: read EVAL.md current state before calling; write ## EDD Context after

**`gsd-validate-phase`** (called by edd-loop, not modified directly)
- edd-loop injects: trigger metric measurement after validation passes

### What is new

| File | Type | Purpose |
|---|---|---|
| `core/skills/edd-loop.md` | Skill (instructions) | Orchestrates the full EDD iteration loop |
| `core/templates/EVAL.md` | Template | Scaffold for new projects |
| `core/templates/LOOP-LOG.md` | Template | Scaffold for new projects |
| `core/context/methodology-guide.md` | Reference doc | Three-tier model — routing, layers, tools |
| `core/scripts/run-metric.sh` | Script | Reads EVAL.md "How to run", executes it, outputs single numeric value |
| `core/scripts/check-stop.sh` | Script | Reads EVAL.md stop criteria + LOOP-LOG history, outputs `STOP <reasons>` or `CONTINUE` |
| `core/scripts/init-eval.sh` | Script | Scaffolds EVAL.md + LOOP-LOG.md from templates into `.planning/` |
| `core/scripts/append-loop-log.sh` | Script | Appends one row to LOOP-LOG.md with correct markdown table formatting |

### What does not change

- `superpowers:test-driven-development` — unchanged
- GSD plan/execute/ship mechanics — unchanged
- Context management rules — unchanged
- Human checkpoints in GSD — EDD checkpoint is additive

### The five seam points

```
1. Brainstorm → EVAL.md
   Success criteria from design doc map to EVAL.md fields.
   ## Methodology Tier in design doc determines if EVAL.md is needed.

2. gsd-discuss-phase → EDD Context in PLAN.md
   edd-loop reads EVAL.md, injects current state, writes hypothesis.
   Human approves PLAN.md including the hypothesis before execution.

3. TDD F→P tests → metric measurement input
   F→P tests that pass are the unit-level eval signal.
   Metric runner references them. No passing F→P tests = no measurement.

4. gsd-validate-phase → LOOP-LOG.md
   Validation passing triggers the metric run.
   Result appended to LOOP-LOG, EVAL.md Current State synced.
   Stop conditions evaluated against updated LOOP-LOG.

5. Stop condition → human checkpoint
   Any condition met surfaces: metric delta, trend, conditions hit, recommendation.
   Human decides. Decision recorded in LOOP-LOG "Decision" column.
```

---

## Implementation Scope

**8 new files, 1 modified file.**

```
core/
  context/
    methodology-guide.md        ← NEW (reference doc)
  skills/
    edd-loop.md                 ← NEW (skill — instructions)
    development-lifecycle.md    ← MODIFIED (tier routing + Tier 3 wrapper)
  templates/                    ← NEW DIRECTORY
    EVAL.md                     ← NEW (template)
    LOOP-LOG.md                 ← NEW (template)
  scripts/                      ← NEW DIRECTORY
    run-metric.sh               ← NEW (executes project metric command)
    check-stop.sh               ← NEW (evaluates stop conditions, outputs STOP/CONTINUE)
    init-eval.sh                ← NEW (scaffolds .planning/EVAL.md + LOOP-LOG.md)
    append-loop-log.sh          ← NEW (appends one row to LOOP-LOG.md)
```

GSD plugin skills are not modified. `edd-loop.md` wraps GSD calls from outside, injecting
EDD context before and after each GSD command. GSD behavior is unchanged.

Scripts are adapter-agnostic — any agent with shell access invokes them via Bash.
No adapter-specific code. Works with Claude Code, Copilot CLI, or any shell-capable agent.

---

## Research Backing

| Finding | Source | Implication |
|---|---|---|
| Continuous reward >> binary pass/fail (34.8 vs 29.0) | SWE-RL (2502.18449) | Eval metric should be continuous, not boolean |
| Self-verification before submitting: 15.9% → 18.5% | SWT-Bench (2406.12952) | TDD discipline (run before submit) measurably improves outcomes |
| Agent self-improvement is progressive with clear metric | Self-Improving Coding Agent (2504.15228) | EDD loop is effective for software agents, not just ML training |
| Human owns strategy (program.md), agent owns implementation | autoresearch (Karpathy) | Human's role is EVAL.md + learnings, not code |
| Overseer monitors loop health, leaves notes for next iteration | Self-Improving Coding Agent | Human checkpoint + LOOP-LOG.md serves the overseer role |

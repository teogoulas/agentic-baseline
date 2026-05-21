# Methodology Guide

Reference document. Read at session start when working on an unfamiliar project.
Answers: "which workflow applies here?" without invoking a skill.

---

## The Three-Layer Model

Three methodologies, three layers. They are not alternatives — they compose vertically.

| Layer | Tool | Answers |
|---|---|---|
| EDD (outermost) | `edd-loop.md` + scripts | *What are we optimizing and are we done?* |
| SDD (middle) | GSD | *What are we building this iteration and in what scope?* |
| TDD (innermost) | Superpowers | *Is this unit correct and does it move the metric?* |

The F→P test written during TDD is not just a quality gate — it is the unit-level eval signal.
The GSD phase boundary is not just a planning artifact — it is the EDD iteration container.
The scalar metric is not just a success criterion — it is what drives what to build next.

---

## Tier Selection

Tier is selected at the end of brainstorming (`superpowers:brainstorming`) and recorded in
the design doc under `## Methodology Tier`. `development-lifecycle.md` reads this field.

**Two routing questions:**

1. *Is "correct" binary and fully pre-specifiable — do tests cover it completely?*
2. *Will this genuinely need multiple sessions?*

| Q1 | Q2 | Tier | Workflow |
|---|---|---|---|
| Yes | No — fits in one session | **1** | superpowers stack (brainstorm → writing-plans → subagent-driven-development) |
| Yes | Yes — genuinely multi-session | **2** | TDD + GSD phases |
| No — fuzzy or discovered | Any | **3** | TDD + GSD + EDD loop (`edd-loop.md`) |

**Key insight:** For single-session work, `subagent-driven-development` provides context isolation via fresh subagents per task — GSD phases add overhead without benefit. GSD is only needed when work genuinely spans multiple sessions and PLAN.md needs to survive a context reset.

When in doubt between Tier 2 and Tier 3: ask "will I know I'm done before I start?" If yes → Tier 2. If no → Tier 3.
When in doubt between Tier 1 and Tier 2: ask "can I finish this in one session?" If yes → Tier 1.

---

## Tier 1 — superpowers stack (one session)

Correct is fully pre-specifiable, fits in one session. Subagent-driven-development provides context isolation — no GSD phases needed.

```
superpowers:brainstorming → superpowers:writing-plans → superpowers:subagent-driven-development → superpowers:finishing-a-development-branch
```

TDD discipline applies inside each subagent task: red → green → refactor. No EVAL.md. No PLAN.md. No GSD phases.

---

## Tier 2 — TDD + GSD (genuinely multi-session)

Correctness is binary but work genuinely spans multiple sessions. PLAN.md survives context resets. GSD phase boundaries provide human checkpoints and resumability.

```
gsd-discuss-phase → gsd-plan-phase → gsd-execute-phase (TDD inside) → gsd-validate-phase → gsd-ship
```

No EVAL.md. No loop. Standard GSD workflow unchanged.

---

## Tier 3 — TDD + SDD + EDD loop

Correctness is fuzzy, discovered through iteration, or you need to optimize against a measurable
target. One phase = one EDD iteration. Stop conditions (time box, target, diminishing returns)
all feed into a human checkpoint — no automatic stops.

```
superpowers:brainstorming → EVAL.md → edd-loop.md (wraps GSD + TDD per iteration) → gsd-ship
```

One script handles deterministic computation; agent instructions handle everything else:
- `core/scripts/check-stop.py` — evaluates stop conditions, outputs STOP/CONTINUE

All other EDD operations (scaffolding EVAL.md, running the metric, appending LOOP-LOG rows) are agent instructions in `core/skills/edd-loop.md`.

---

## Human role in Tier 3

The human owns `.planning/EVAL.md` — specifically the strategy:
- The metric definition (what to optimize)
- The stop criteria (when to stop)
- The learnings section (updated between iterations)

The agent owns implementation. This mirrors Karpathy's autoresearch: the human writes
`program.md` (strategy), the agent edits `train.py` (implementation).

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
2. *Is scope large enough to risk context rot across sessions?*

| Q1 | Q2 | Tier | Workflow |
|---|---|---|---|
| Yes | No — small, one session | **1** | TDD only (`superpowers:test-driven-development`) |
| Yes | Yes — large or multi-session | **2** | TDD + SDD (standard GSD flow) |
| No — fuzzy or discovered | Any | **3** | TDD + SDD + EDD loop (`edd-loop.md`) |

When in doubt between Tier 2 and Tier 3: ask "will I know I'm done before I start?" If yes → Tier 2. If no → Tier 3.

---

## Tier 1 — TDD only

Simple, self-contained. Correct is obvious upfront. One session.

```
superpowers:test-driven-development → red → green → refactor → done
```

No EVAL.md. No PLAN.md. No loop. `gsd-quick` for commit scaffold if needed.

---

## Tier 2 — TDD + SDD

Larger scope, multi-session, correctness is binary. Context isolation needed, metric adds no value.

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

Scripts handle all deterministic computation:
- `core/scripts/run-metric.sh` — executes the project metric command
- `core/scripts/check-stop.py` — evaluates stop conditions, outputs STOP/CONTINUE
- `core/scripts/init-eval.sh` — scaffolds `.planning/EVAL.md` + `.planning/LOOP-LOG.md`
- `core/scripts/append-loop-log.sh` — appends one row to `.planning/LOOP-LOG.md`

---

## Human role in Tier 3

The human owns `.planning/EVAL.md` — specifically the strategy:
- The metric definition (what to optimize)
- The stop criteria (when to stop)
- The learnings section (updated between iterations)

The agent owns implementation. This mirrors Karpathy's autoresearch: the human writes
`program.md` (strategy), the agent edits `train.py` (implementation).

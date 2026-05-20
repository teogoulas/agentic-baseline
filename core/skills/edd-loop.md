---
name: edd-loop
description: Eval-Driven Development loop orchestrator — runs the EDD iteration cycle for Tier 3 projects. Invokes GSD commands with EDD context injected, runs metric scripts, evaluates stop conditions, and surfaces human checkpoints. Use when development-lifecycle.md routes to Tier 3.
---

# EDD Loop

## Pre-loop — run once per project

Run these steps before the first iteration.

**1. Confirm EVAL.md exists and baseline is populated.**

If `.planning/EVAL.md` does not exist:
```bash
bash core/scripts/init-eval.sh
```
Open `.planning/EVAL.md` and fill in all fields. The `**Baseline**` value is TBD at this stage.

**2. Measure baseline.**

```bash
bash core/scripts/run-metric.sh
```

If `run-metric.sh` exits non-zero: stop. Ask the user to redefine the metric or downgrade to Tier 2.

Record the output value in `.planning/EVAL.md` under `**Baseline > Value:**` and `**Current State > Value:**`.

**3. Append baseline row to LOOP-LOG.md.**

```bash
bash core/scripts/append-loop-log.sh 0 "baseline" "—" "<baseline_value>" "—" "—" "—"
```

---

## Per-iteration — repeat until exit

### Step 1 — Hypothesize

Before doing anything else, write one sentence:

> "Building [X] will move [metric] from [current value] toward [target] because [reason]."

This is the hypothesis for this iteration. It goes into the PLAN.md EDD Context section.

### Step 2 — SDD scope (gsd-discuss-phase)

Read `.planning/EVAL.md` current state before calling. Note:
- Current metric value and trend
- Which stop conditions are currently active
- Learnings from the previous iteration

Call:
```
/gsd-discuss-phase <N>
```

Scale depth to hypothesis size:
- Small hypothesis (change within one component) → brief discuss, skip if scope is obvious
- Medium hypothesis (spans multiple components) → full discuss with questions
- Large hypothesis (architectural or cross-cutting) → full discuss + spike if needed

After discuss, ensure the phase scope document includes the hypothesis.

### Step 3 — SDD plan (gsd-plan-phase)

```
/gsd-plan-phase <N>
```

The PLAN.md for this phase MUST include a `## EDD Context` section:

```markdown
## EDD Context
**Hypothesis:**    [the one-sentence hypothesis from Step 1]
**Metric before:** [current value from .planning/LOOP-LOG.md latest row]
**Expected delta:** [+/− X units]
**Stop conditions status:**
  - Time box:            [elapsed]d / [limit]d
  - Target:              [current] / [target]
  - Diminishing returns: [N] consecutive below threshold / [stagnation_count]
```

**Human checkpoint:** present PLAN.md including EDD Context. Wait for explicit approval before executing.

### Step 4 — TDD execute

```
Skill("superpowers:test-driven-development")
/gsd-execute-phase <N>
```

Write the F→P test before implementation. The failing test is the unit eval signal — it
specifies what must be true for this unit to have moved the metric needle.

All units in the phase follow: Red → Green → Refactor.

### Step 5 — Validate

```
/gsd-validate-phase <N>
/gsd-code-review
```

All F→P tests must pass before measuring. If validation fails: fix, do not measure.
A failing test suite never produces a LOOP-LOG entry.

### Step 6 — Measure

```bash
bash core/scripts/run-metric.sh
```

Record the output as `metric_after`. Compute `delta = metric_after − metric_before`.

Append to LOOP-LOG (replace placeholders):
```bash
bash core/scripts/append-loop-log.sh \
  <N> "<hypothesis>" <metric_before> <metric_after> <delta> "TBD" "TBD"
```

Update `.planning/EVAL.md` Current State:
```
**Value:**        <metric_after>
**Iteration:**    <N>
**Trend:**        [improving if delta positive/better, stagnant if below threshold, regressing if negative/worse]
**Last updated:** <today>
```

### Step 7 — Stop check

```bash
python3 core/scripts/check-stop.py
```

Output is either `CONTINUE` or `STOP` followed by `CONDITIONS:` and a list of triggered conditions.

If `CONTINUE`: update the LOOP-LOG decision column to "continue" and proceed to Step 8 (skip human checkpoint unless you want one).

If `STOP`: go to Step 8 (human checkpoint required).

### Step 8 — Human checkpoint

Present to the user:

```
Metric:         [before] → [after]  (delta: [+/−X])
Trend:          [improving / stagnant / regressing over last N iterations]
Conditions hit: [list from check-stop.py, or "none"]
Recommendation: [continue / stop — one sentence reason]
```

Ask: **"Continue the loop or exit?"**

- **Continue:** update LOOP-LOG decision column to "continue". Update EVAL.md learnings
  with what this iteration revealed. Set next hypothesis. Return to Step 1.
- **Exit:** update LOOP-LOG decision column to "stop (human)". Proceed to post-loop.

---

## Post-loop — run once on exit

```bash
# Archive LOOP-LOG
mkdir -p .planning/loop-logs
cp .planning/LOOP-LOG.md ".planning/loop-logs/$(date +%Y-%m-%d)-<slug>.md"
```

Update `.planning/EVAL.md`:
```
**metric_final:** <final value>
**exit_reason:**  [target_reached | time_box | diminishing_returns | human_decision]
**date_closed:**  <today>
```

Then:
```
/gsd-ship
/gsd-extract-learnings
```

---

## Error handling

| Situation | Action |
|---|---|
| `run-metric.sh` exits non-zero | Stop. Ask user to fix the metric command in EVAL.md or downgrade to Tier 2. |
| `check-stop.py` exits non-zero | Stop. Check EVAL.md fields are all populated. |
| Validation fails (gsd-validate-phase) | Fix failing tests. Do not measure. Do not append LOOP-LOG. |
| Human decides to exit mid-iteration | Record decision in LOOP-LOG. Proceed to post-loop from current state. |

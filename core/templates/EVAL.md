# EVAL — [Project/Feature Name]

## Metric
**Name:**        [what you are measuring — e.g. "test pass rate", "p95 latency", "coverage %"]
**Definition:**  [precise calculation reproducible by anyone]
**Unit:**        [%, ms, score, count]
**Direction:**   [higher | lower]
**How to run:**  [single shell command that outputs one numeric value — e.g. `pytest --tb=no -q | grep passed | grep -oE '[0-9]+'`]

## Baseline
**Value:**    [populated by run-metric.sh after first run]
**Date:**     [YYYY-MM-DD]
**Context:**  [one sentence — codebase state when measured]

## Target
**Value:**      [numeric target — same unit as metric]
**Rationale:**  [why this target]

## Stop Criteria
**Time box:**         [number of days — e.g. 14]
**Target threshold:** [numeric value — metric value that counts as "reached"]
**Delta threshold:**  [numeric — minimum meaningful improvement per iteration, same unit as metric]
**Stagnation count:** [integer — consecutive iterations below delta threshold before flagging]

## Current State
**Value:**        [updated by agent after each iteration]
**Iteration:**    0
**Trend:**        [improving | stagnant | regressing]
**Last updated:** [YYYY-MM-DD]

## Learnings
[Human updates between iterations. Strategy notes, revised hypotheses, what worked, what did not.]

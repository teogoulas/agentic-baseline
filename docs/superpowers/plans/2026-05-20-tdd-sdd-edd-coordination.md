# TDD + SDD + EDD Coordination Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend the agentic-baseline-repo with a hybrid EDD coordination layer — bash/Python scripts for reliable metric computation and stop-condition evaluation, plus markdown skills for loop orchestration and tier routing.

**Architecture:** Four scripts handle all deterministic computation (metric execution, stop-condition evaluation, artifact scaffolding, log appending). A new `edd-loop.md` skill orchestrates the iteration loop by invoking GSD commands with EDD context injected around them. `development-lifecycle.md` gains a tier-routing step that selects TDD-only, TDD+SDD, or the full EDD loop based on project characteristics identified at brainstorm time.

**Tech Stack:** Bash (init, run-metric, append-log), Python 3 (check-stop — markdown parsing requires more than grep/awk), Markdown (skills, templates, reference docs).

---

## File Map

| File | Action | Responsibility |
|---|---|---|
| `core/templates/EVAL.md` | Create | Project metric definition scaffold |
| `core/templates/LOOP-LOG.md` | Create | Iteration history scaffold |
| `core/scripts/tests/helpers.sh` | Create | Shared test utilities (assert_eq, assert_contains, setup_tmp) |
| `core/scripts/tests/run_all.sh` | Create | Test runner — runs all test files, reports pass/fail |
| `core/scripts/init-eval.sh` | Create | Scaffold `.planning/EVAL.md` + `.planning/LOOP-LOG.md` from templates |
| `core/scripts/tests/test_init_eval.sh` | Create | Tests for init-eval.sh |
| `core/scripts/run-metric.sh` | Create | Read EVAL.md "How to run", execute it, output single numeric value |
| `core/scripts/tests/test_run_metric.sh` | Create | Tests for run-metric.sh |
| `core/scripts/append-loop-log.sh` | Create | Append one formatted row to `.planning/LOOP-LOG.md` |
| `core/scripts/tests/test_append_loop_log.sh` | Create | Tests for append-loop-log.sh |
| `core/scripts/check-stop.py` | Create | Parse EVAL.md stop criteria + LOOP-LOG history, output STOP/CONTINUE |
| `core/scripts/tests/test_check_stop.py` | Create | Tests for check-stop.py |
| `core/skills/edd-loop.md` | Create | EDD iteration loop — pre-loop, per-iteration, stop-check, post-loop |
| `core/context/methodology-guide.md` | Create | Three-tier model reference — routing decision, layer responsibilities |
| `core/skills/development-lifecycle.md` | Modify | Add tier routing after brainstorm; wrap Tier 3 in edd-loop |

---

## Task 1: Test infrastructure

**Files:**
- Create: `core/scripts/tests/helpers.sh`
- Create: `core/scripts/tests/run_all.sh`

- [ ] **Step 1: Create test helpers**

```bash
# core/scripts/tests/helpers.sh
#!/usr/bin/env bash
PASS=0
FAIL=0

assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc"
    echo "        expected: $expected"
    echo "        actual:   $actual"
    FAIL=$((FAIL + 1))
  fi
}

assert_contains() {
  local desc="$1" needle="$2" haystack="$3"
  if echo "$haystack" | grep -qF "$needle"; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc"
    echo "        expected to contain: $needle"
    echo "        actual: $haystack"
    FAIL=$((FAIL + 1))
  fi
}

assert_exit_code() {
  local desc="$1" expected="$2" actual="$3"
  assert_eq "$desc (exit code)" "$expected" "$actual"
}

setup_tmp() {
  TMP=$(mktemp -d)
  mkdir -p "$TMP/.planning"
  trap 'rm -rf "$TMP"' EXIT
}

report() {
  echo ""
  echo "Results: $PASS passed, $FAIL failed"
  [ "$FAIL" -eq 0 ]
}
```

- [ ] **Step 2: Create test runner**

```bash
# core/scripts/tests/run_all.sh
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TOTAL_PASS=0
TOTAL_FAIL=0

for f in "$SCRIPT_DIR"/test_*.sh; do
  echo "=== $(basename "$f") ==="
  bash "$f"
  echo ""
done

for f in "$SCRIPT_DIR"/test_*.py; do
  echo "=== $(basename "$f") ==="
  python3 "$f"
  echo ""
done

echo "All test suites complete."
```

- [ ] **Step 3: Make executable and commit**

```bash
chmod +x core/scripts/tests/helpers.sh core/scripts/tests/run_all.sh
git add core/scripts/tests/
git commit -m "test: add script test infrastructure"
```

---

## Task 2: EVAL.md and LOOP-LOG.md templates

**Files:**
- Create: `core/templates/EVAL.md`
- Create: `core/templates/LOOP-LOG.md`

- [ ] **Step 1: Create EVAL.md template**

```markdown
<!-- core/templates/EVAL.md -->
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
```

- [ ] **Step 2: Create LOOP-LOG.md template**

```markdown
<!-- core/templates/LOOP-LOG.md -->
# Loop Log — [Project/Feature Name]

| # | Hypothesis | Before | After | Delta | Conditions hit | Decision | Date |
|---|---|---|---|---|---|---|---|
| 0 | baseline | — | [value] | — | — | — | [YYYY-MM-DD] |
```

- [ ] **Step 3: Commit**

```bash
mkdir -p core/templates
git add core/templates/
git commit -m "feat: add EVAL.md and LOOP-LOG.md scaffold templates"
```

---

## Task 3: init-eval.sh

**Files:**
- Create: `core/scripts/init-eval.sh`
- Create: `core/scripts/tests/test_init_eval.sh`

- [ ] **Step 1: Write the failing test**

```bash
# core/scripts/tests/test_init_eval.sh
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"
INIT_SCRIPT="$SCRIPT_DIR/../init-eval.sh"

echo "--- test_init_eval ---"

# Test 1: creates both files in .planning/
setup_tmp
PLANNING_DIR="$TMP/.planning" TEMPLATES_DIR="$SCRIPT_DIR/../../templates" \
  bash "$INIT_SCRIPT" 2>/dev/null
assert_eq "creates EVAL.md" "true" "$([ -f "$TMP/.planning/EVAL.md" ] && echo true || echo false)"
assert_eq "creates LOOP-LOG.md" "true" "$([ -f "$TMP/.planning/LOOP-LOG.md" ] && echo true || echo false)"

# Test 2: skips existing files without FORCE
setup_tmp
echo "original" > "$TMP/.planning/EVAL.md"
OUT=$(PLANNING_DIR="$TMP/.planning" TEMPLATES_DIR="$SCRIPT_DIR/../../templates" \
  bash "$INIT_SCRIPT" 2>&1)
assert_contains "skips existing EVAL.md" "SKIP" "$OUT"
assert_eq "does not overwrite EVAL.md" "original" "$(cat "$TMP/.planning/EVAL.md")"

# Test 3: overwrites with FORCE=1
setup_tmp
echo "original" > "$TMP/.planning/EVAL.md"
FORCE=1 PLANNING_DIR="$TMP/.planning" TEMPLATES_DIR="$SCRIPT_DIR/../../templates" \
  bash "$INIT_SCRIPT" 2>/dev/null
assert_eq "overwrites with FORCE=1" "false" \
  "$(grep -q 'original' "$TMP/.planning/EVAL.md" && echo true || echo false)"

# Test 4: exits non-zero if templates missing
setup_tmp
OUT=$(PLANNING_DIR="$TMP/.planning" TEMPLATES_DIR="$TMP/no-templates" \
  bash "$INIT_SCRIPT" 2>&1) || true
assert_contains "errors on missing templates" "ERROR" "$OUT"

report
```

- [ ] **Step 2: Run test to verify it fails**

```bash
bash core/scripts/tests/test_init_eval.sh
```

Expected: FAIL (script does not exist yet)

- [ ] **Step 3: Implement init-eval.sh**

```bash
# core/scripts/init-eval.sh
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="${TEMPLATES_DIR:-$SCRIPT_DIR/../templates}"
PLANNING_DIR="${PLANNING_DIR:-.planning}"
FORCE="${FORCE:-0}"

[ -f "$TEMPLATES_DIR/EVAL.md" ] \
  || { echo "ERROR: $TEMPLATES_DIR/EVAL.md not found" >&2; exit 1; }
[ -f "$TEMPLATES_DIR/LOOP-LOG.md" ] \
  || { echo "ERROR: $TEMPLATES_DIR/LOOP-LOG.md not found" >&2; exit 1; }

mkdir -p "$PLANNING_DIR"

for f in EVAL.md LOOP-LOG.md; do
  if [ -f "$PLANNING_DIR/$f" ] && [ "$FORCE" != "1" ]; then
    echo "SKIP: $PLANNING_DIR/$f already exists (set FORCE=1 to overwrite)"
  else
    cp "$TEMPLATES_DIR/$f" "$PLANNING_DIR/$f"
    echo "Created $PLANNING_DIR/$f"
  fi
done
```

- [ ] **Step 4: Run test to verify it passes**

```bash
bash core/scripts/tests/test_init_eval.sh
```

Expected: 4 PASS, 0 FAIL

- [ ] **Step 5: Make executable and commit**

```bash
chmod +x core/scripts/init-eval.sh
git add core/scripts/
git commit -m "feat: add init-eval.sh with tests"
```

---

## Task 4: run-metric.sh

**Files:**
- Create: `core/scripts/run-metric.sh`
- Create: `core/scripts/tests/test_run_metric.sh`

- [ ] **Step 1: Write the failing test**

```bash
# core/scripts/tests/test_run_metric.sh
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"
RUN_SCRIPT="$SCRIPT_DIR/../run-metric.sh"

echo "--- test_run_metric ---"

# Test 1: runs command from EVAL.md and outputs its numeric result
setup_tmp
cat > "$TMP/.planning/EVAL.md" <<'EOF'
# EVAL
**How to run:** echo 42
EOF
RESULT=$(EVAL_FILE="$TMP/.planning/EVAL.md" bash "$RUN_SCRIPT")
assert_eq "outputs numeric result" "42" "$RESULT"

# Test 2: works with decimal output
setup_tmp
cat > "$TMP/.planning/EVAL.md" <<'EOF'
# EVAL
**How to run:** echo 87.5
EOF
RESULT=$(EVAL_FILE="$TMP/.planning/EVAL.md" bash "$RUN_SCRIPT")
assert_eq "outputs decimal result" "87.5" "$RESULT"

# Test 3: exits non-zero when EVAL.md missing
OUT=$(EVAL_FILE="/no/such/file" bash "$RUN_SCRIPT" 2>&1) || CODE=$?
assert_contains "errors on missing EVAL.md" "ERROR" "$OUT"

# Test 4: exits non-zero when How to run missing
setup_tmp
cat > "$TMP/.planning/EVAL.md" <<'EOF'
# EVAL
**Name:** something
EOF
OUT=$(EVAL_FILE="$TMP/.planning/EVAL.md" bash "$RUN_SCRIPT" 2>&1) || true
assert_contains "errors on missing How to run" "ERROR" "$OUT"

# Test 5: exits non-zero when command output is not numeric
setup_tmp
cat > "$TMP/.planning/EVAL.md" <<'EOF'
# EVAL
**How to run:** echo "not a number"
EOF
OUT=$(EVAL_FILE="$TMP/.planning/EVAL.md" bash "$RUN_SCRIPT" 2>&1) || true
assert_contains "errors on non-numeric output" "ERROR" "$OUT"

# Test 6: exits non-zero when command itself fails
setup_tmp
cat > "$TMP/.planning/EVAL.md" <<'EOF'
# EVAL
**How to run:** exit 1
EOF
OUT=$(EVAL_FILE="$TMP/.planning/EVAL.md" bash "$RUN_SCRIPT" 2>&1) || true
assert_contains "errors on command failure" "ERROR" "$OUT"

report
```

- [ ] **Step 2: Run test to verify it fails**

```bash
bash core/scripts/tests/test_run_metric.sh
```

Expected: FAIL (script does not exist yet)

- [ ] **Step 3: Implement run-metric.sh**

```bash
# core/scripts/run-metric.sh
#!/usr/bin/env bash
set -euo pipefail

EVAL_FILE="${EVAL_FILE:-.planning/EVAL.md}"

[ -f "$EVAL_FILE" ] \
  || { echo "ERROR: $EVAL_FILE not found. Run init-eval.sh first." >&2; exit 1; }

CMD=$(grep -E '^\*\*How to run:\*\*' "$EVAL_FILE" \
  | sed 's/^\*\*How to run:\*\* //' \
  | sed 's/^`//;s/`$//')

[ -n "$CMD" ] \
  || { echo "ERROR: 'How to run' field not set in $EVAL_FILE" >&2; exit 1; }

RESULT=$(eval "$CMD" 2>&1) || {
  echo "ERROR: metric command failed: $RESULT" >&2
  exit 1
}

echo "$RESULT" | grep -qE '^-?[0-9]+(\.[0-9]+)?$' \
  || { echo "ERROR: command output is not numeric: '$RESULT'" >&2; exit 1; }

echo "$RESULT"
```

- [ ] **Step 4: Run test to verify it passes**

```bash
bash core/scripts/tests/test_run_metric.sh
```

Expected: 6 PASS, 0 FAIL

- [ ] **Step 5: Make executable and commit**

```bash
chmod +x core/scripts/run-metric.sh
git add core/scripts/
git commit -m "feat: add run-metric.sh with tests"
```

---

## Task 5: append-loop-log.sh

**Files:**
- Create: `core/scripts/append-loop-log.sh`
- Create: `core/scripts/tests/test_append_loop_log.sh`

- [ ] **Step 1: Write the failing test**

```bash
# core/scripts/tests/test_append_loop_log.sh
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"
APPEND_SCRIPT="$SCRIPT_DIR/../append-loop-log.sh"

echo "--- test_append_loop_log ---"

# Test 1: appends a correctly formatted row
setup_tmp
printf "| # | Hypothesis | Before | After | Delta | Conditions hit | Decision | Date |\n" \
  > "$TMP/.planning/LOOP-LOG.md"
LOG_FILE="$TMP/.planning/LOOP-LOG.md" \
  bash "$APPEND_SCRIPT" 1 "build X to move M" 42 45 "+3" "none" "continue"
LINE=$(tail -1 "$TMP/.planning/LOOP-LOG.md")
assert_contains "contains iteration number" "| 1 |" "$LINE"
assert_contains "contains hypothesis" "build X to move M" "$LINE"
assert_contains "contains before" "| 42 |" "$LINE"
assert_contains "contains after" "| 45 |" "$LINE"
assert_contains "contains delta" "| +3 |" "$LINE"
assert_contains "contains decision" "continue" "$LINE"

# Test 2: exits non-zero with wrong arg count
OUT=$(LOG_FILE="$TMP/.planning/LOOP-LOG.md" bash "$APPEND_SCRIPT" 1 "h" 2>&1) || true
assert_contains "errors on wrong arg count" "Usage" "$OUT"

# Test 3: exits non-zero when log file missing
OUT=$(LOG_FILE="/no/such/file" \
  bash "$APPEND_SCRIPT" 1 "h" 0 0 0 "none" "continue" 2>&1) || true
assert_contains "errors on missing log file" "ERROR" "$OUT"

# Test 4: multiple appends produce multiple rows
setup_tmp
printf "| # | Hypothesis | Before | After | Delta | Conditions hit | Decision | Date |\n" \
  > "$TMP/.planning/LOOP-LOG.md"
LOG_FILE="$TMP/.planning/LOOP-LOG.md" \
  bash "$APPEND_SCRIPT" 1 "first" 10 12 "+2" "none" "continue"
LOG_FILE="$TMP/.planning/LOOP-LOG.md" \
  bash "$APPEND_SCRIPT" 2 "second" 12 13 "+1" "none" "continue"
COUNT=$(grep -c '^\|' "$TMP/.planning/LOOP-LOG.md")
assert_eq "three rows total (header + 2 data)" "3" "$COUNT"

report
```

- [ ] **Step 2: Run test to verify it fails**

```bash
bash core/scripts/tests/test_append_loop_log.sh
```

Expected: FAIL (script does not exist yet)

- [ ] **Step 3: Implement append-loop-log.sh**

```bash
# core/scripts/append-loop-log.sh
#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${LOG_FILE:-.planning/LOOP-LOG.md}"

if [ $# -ne 7 ]; then
  echo "Usage: $(basename "$0") <iteration> <hypothesis> <before> <after> <delta> <conditions> <decision>" >&2
  exit 1
fi

[ -f "$LOG_FILE" ] \
  || { echo "ERROR: $LOG_FILE not found. Run init-eval.sh first." >&2; exit 1; }

DATE=$(date +%Y-%m-%d)
printf "| %s | %s | %s | %s | %s | %s | %s | %s |\n" \
  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$DATE" >> "$LOG_FILE"
echo "Appended iteration $1 to $LOG_FILE"
```

- [ ] **Step 4: Run test to verify it passes**

```bash
bash core/scripts/tests/test_append_loop_log.sh
```

Expected: 7 PASS, 0 FAIL

- [ ] **Step 5: Make executable and commit**

```bash
chmod +x core/scripts/append-loop-log.sh
git add core/scripts/
git commit -m "feat: add append-loop-log.sh with tests"
```

---

## Task 6: check-stop.py

Python is used here (not bash) because reliable markdown parsing and multi-condition numeric
evaluation require more than grep/awk. The script is invoked exactly like the others:
`python3 core/scripts/check-stop.py`

**Files:**
- Create: `core/scripts/check-stop.py`
- Create: `core/scripts/tests/test_check_stop.py`

- [ ] **Step 1: Write the failing test**

```python
# core/scripts/tests/test_check_stop.py
import subprocess, sys, os, tempfile, textwrap
from pathlib import Path

SCRIPT = Path(__file__).parent.parent / "check-stop.py"
PASS = FAIL = 0

def run(eval_content, log_content):
    with tempfile.TemporaryDirectory() as tmp:
        planning = Path(tmp) / ".planning"
        planning.mkdir()
        (planning / "EVAL.md").write_text(textwrap.dedent(eval_content))
        (planning / "LOOP-LOG.md").write_text(textwrap.dedent(log_content))
        env = {**os.environ,
               "EVAL_FILE": str(planning / "EVAL.md"),
               "LOG_FILE":  str(planning / "LOOP-LOG.md")}
        result = subprocess.run(
            [sys.executable, str(SCRIPT)],
            capture_output=True, text=True, env=env)
        return result.stdout.strip(), result.returncode

def assert_eq(desc, expected, actual):
    global PASS, FAIL
    if expected == actual:
        print(f"  PASS: {desc}")
        PASS += 1
    else:
        print(f"  FAIL: {desc}\n        expected: {expected!r}\n        actual:   {actual!r}")
        FAIL += 1

def assert_contains(desc, needle, haystack):
    global PASS, FAIL
    if needle in haystack:
        print(f"  PASS: {desc}")
        PASS += 1
    else:
        print(f"  FAIL: {desc}\n        expected to contain: {needle!r}\n        actual: {haystack!r}")
        FAIL += 1

print("--- test_check_stop ---")

EVAL_BASE = """\
# EVAL
**Direction:** higher
**Time box:** 14
**Target threshold:** 90
**Delta threshold:** 2
**Stagnation count:** 2
"""

LOG_BASE = """\
| # | Hypothesis | Before | After | Delta | Conditions hit | Decision | Date |
|---|---|---|---|---|---|---|---|
| 0 | baseline | — | 60 | — | — | — | 2026-01-01 |
"""

# Test 1: CONTINUE when no conditions met
log = LOG_BASE + "| 1 | h1 | 60 | 65 | +5 | none | continue | 2026-01-03 |\n"
out, _ = run(EVAL_BASE, log)
assert_eq("CONTINUE when no conditions met", "CONTINUE", out)

# Test 2: STOP on target reached (higher)
log = LOG_BASE + "| 1 | h1 | 60 | 91 | +31 | none | continue | 2026-01-03 |\n"
out, _ = run(EVAL_BASE, log)
assert_eq("STOP first line on target reached", "STOP", out.splitlines()[0])
assert_contains("mentions target condition", "target", out)

# Test 3: STOP on diminishing returns (2 consecutive below threshold of 2)
log = (LOG_BASE
       + "| 1 | h1 | 60 | 61 | +1 | none | continue | 2026-01-03 |\n"
       + "| 2 | h2 | 61 | 62 | +1 | none | continue | 2026-01-05 |\n")
out, _ = run(EVAL_BASE, log)
assert_eq("STOP first line on diminishing returns", "STOP", out.splitlines()[0])
assert_contains("mentions diminishing_returns", "diminishing_returns", out)

# Test 4: does NOT flag diminishing returns with only 1 iteration below threshold
log = (LOG_BASE
       + "| 1 | h1 | 60 | 65 | +5 | none | continue | 2026-01-03 |\n"
       + "| 2 | h2 | 65 | 66 | +1 | none | continue | 2026-01-05 |\n")
out, _ = run(EVAL_BASE, log)
assert_eq("CONTINUE with only 1 stagnant iteration", "CONTINUE", out)

# Test 5: STOP on time box (use a start date far in the past)
log = LOG_BASE.replace("2026-01-01", "2020-01-01")
out, _ = run(EVAL_BASE, log)
assert_eq("STOP first line on time box", "STOP", out.splitlines()[0])
assert_contains("mentions time_box", "time_box", out)

# Test 6: multiple conditions — all reported
log = (LOG_BASE.replace("2026-01-01", "2020-01-01")
       + "| 1 | h1 | 60 | 91 | +31 | none | continue | 2020-01-03 |\n"
       + "| 2 | h2 | 91 | 92 | +1 | none | continue | 2020-01-05 |\n"
       + "| 3 | h3 | 92 | 93 | +1 | none | continue | 2020-01-07 |\n")
out, _ = run(EVAL_BASE, log)
assert_eq("STOP on multiple conditions", "STOP", out.splitlines()[0])
assert_contains("reports target", "target", out)
assert_contains("reports time_box", "time_box", out)

# Test 7: lower-is-better direction
eval_lower = EVAL_BASE.replace("**Direction:** higher", "**Direction:** lower") \
                      .replace("**Target threshold:** 90", "**Target threshold:** 30")
log = LOG_BASE + "| 1 | h1 | 60 | 28 | -32 | none | continue | 2026-01-03 |\n"
out, _ = run(eval_lower, log)
assert_eq("STOP first line for lower-is-better target", "STOP", out.splitlines()[0])
assert_contains("mentions target (lower)", "target", out)

print(f"\nResults: {PASS} passed, {FAIL} failed")
sys.exit(0 if FAIL == 0 else 1)
```

- [ ] **Step 2: Run test to verify it fails**

```bash
python3 core/scripts/tests/test_check_stop.py
```

Expected: errors/failures (script does not exist yet)

- [ ] **Step 3: Implement check-stop.py**

```python
#!/usr/bin/env python3
"""
Reads EVAL.md stop criteria and LOOP-LOG.md history.
Outputs:  CONTINUE
    or:   STOP
          CONDITIONS:
          - reason1
          - reason2
"""
import sys, re, os
from datetime import date, datetime

EVAL_FILE = os.environ.get("EVAL_FILE", ".planning/EVAL.md")
LOG_FILE  = os.environ.get("LOG_FILE",  ".planning/LOOP-LOG.md")


def field(text, name):
    m = re.search(rf'\*\*{re.escape(name)}:\*\*\s*(.+)', text)
    return m.group(1).strip() if m else None


def to_float(s):
    if not s:
        return None
    m = re.search(r'-?[\d.]+', s)
    return float(m.group()) if m else None


def parse_log_rows(text):
    rows = []
    for line in text.splitlines():
        cols = [c.strip() for c in line.split("|")]
        if len(cols) < 9:
            continue
        try:
            n = int(cols[1])
        except ValueError:
            continue
        rows.append(dict(n=n, before=cols[3], after=cols[4],
                         delta=cols[5], date=cols[8]))
    return sorted(rows, key=lambda r: r["n"])


def main():
    for path in [EVAL_FILE, LOG_FILE]:
        if not os.path.exists(path):
            print(f"ERROR: {path} not found", file=sys.stderr)
            sys.exit(1)

    eval_text = open(EVAL_FILE).read()
    log_text  = open(LOG_FILE).read()

    direction       = (field(eval_text, "Direction") or "higher").strip().lower()
    time_box_days   = to_float(field(eval_text, "Time box"))
    target_thresh   = to_float(field(eval_text, "Target threshold"))
    delta_thresh    = to_float(field(eval_text, "Delta threshold"))
    stagnation_cnt  = int(to_float(field(eval_text, "Stagnation count")) or 0)

    rows = parse_log_rows(log_text)
    data_rows = [r for r in rows if r["n"] > 0]

    conditions = []

    # 1 — Time box
    if time_box_days is not None:
        baseline = next((r for r in rows if r["n"] == 0), None)
        if baseline and re.match(r'\d{4}-\d{2}-\d{2}', baseline["date"]):
            start = datetime.strptime(baseline["date"], "%Y-%m-%d").date()
            elapsed = (date.today() - start).days
            if elapsed >= time_box_days:
                conditions.append(
                    f"time_box: {elapsed}d elapsed of {int(time_box_days)}d limit")

    # 2 — Target threshold
    if target_thresh is not None and data_rows:
        current = to_float(data_rows[-1]["after"])
        if current is not None:
            hit = (current >= target_thresh) if "higher" in direction \
                  else (current <= target_thresh)
            if hit:
                op = ">=" if "higher" in direction else "<="
                conditions.append(f"target: {current} {op} {target_thresh}")

    # 3 — Diminishing returns
    if delta_thresh is not None and stagnation_cnt > 0 and \
            len(data_rows) >= stagnation_cnt:
        recent = data_rows[-stagnation_cnt:]
        below = [r for r in recent
                 if to_float(r["delta"]) is not None
                 and abs(to_float(r["delta"])) < delta_thresh]
        if len(below) >= stagnation_cnt:
            conditions.append(
                f"diminishing_returns: {stagnation_cnt} consecutive "
                f"iterations below {delta_thresh} threshold")

    if conditions:
        print("STOP")
        print("CONDITIONS:")
        for c in conditions:
            print(f"- {c}")
    else:
        print("CONTINUE")


if __name__ == "__main__":
    main()
```

- [ ] **Step 4: Run test to verify it passes**

```bash
python3 core/scripts/tests/test_check_stop.py
```

Expected: 10 PASS, 0 FAIL

- [ ] **Step 5: Make executable and commit**

```bash
chmod +x core/scripts/check-stop.py
git add core/scripts/
git commit -m "feat: add check-stop.py with tests"
```

---

## Task 7: Run full test suite

**Files:** none (validation only)

- [ ] **Step 1: Run all tests**

```bash
bash core/scripts/tests/run_all.sh
```

Expected: all test suites pass with 0 FAIL

- [ ] **Step 2: Commit if any fixes were needed**

Only if you fixed bugs in previous tasks:
```bash
git add core/scripts/
git commit -m "fix: correct script bugs found during full test run"
```

---

## Task 8: edd-loop.md skill

**Files:**
- Create: `core/skills/edd-loop.md`

No automated tests — skill files are verified by reading them against the spec.

- [ ] **Step 1: Write edd-loop.md**

```markdown
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
python3 core/scripts/check-stop.py  # confirm script can read EVAL.md
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
```

- [ ] **Step 2: Commit**

```bash
git add core/skills/edd-loop.md
git commit -m "feat: add edd-loop.md skill"
```

---

## Task 9: methodology-guide.md

**Files:**
- Create: `core/context/methodology-guide.md`

- [ ] **Step 1: Write methodology-guide.md**

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add core/context/methodology-guide.md
git commit -m "feat: add methodology-guide.md — three-tier model reference"
```

---

## Task 10: Update development-lifecycle.md

**Files:**
- Modify: `core/skills/development-lifecycle.md`

- [ ] **Step 1: Read current file**

Read `core/skills/development-lifecycle.md` in full before editing.

- [ ] **Step 2: Add tier routing after Stage 1**

Find the section after Stage 1 (Brainstorm) and insert this block:

```markdown
## Tier Routing

Immediately after Stage 1, read the brainstorm design doc for `## Methodology Tier`.

| Tier | Condition | Action |
|---|---|---|
| 1 | Binary correctness, small scope | `Skill("superpowers:test-driven-development")` — skip to Stage 5 when done |
| 2 | Binary correctness, large scope | Continue to Stage 2 (standard SDD flow) |
| 3 | Fuzzy correctness or iterative | `Skill("edd-loop")` — edd-loop wraps Stages 2–4 per iteration |

If `## Methodology Tier` is not present in the design doc: ask the user before proceeding.
```

- [ ] **Step 3: Add Tier 3 note to Stage 3 (Execute)**

In Stage 3, after the TDD invocation line, add:

```markdown
**Tier 3 note:** TDD runs exactly as in Tier 1/2. `edd-loop.md` measures the metric after
`gsd-validate-phase` passes — no change to the TDD cycle itself.
```

- [ ] **Step 4: Add Tier 3 note to Stage 4 (Validate)**

In Stage 4, after the validate commands, add:

```markdown
**Tier 3 note:** After validation passes, return to `edd-loop.md` Step 6 (Measure).
Do not proceed to Stage 5 until the EDD loop exits.
```

- [ ] **Step 5: Verify the file reads cleanly**

Read the full updated `core/skills/development-lifecycle.md` and confirm:
- Tier routing block is present after Stage 1
- Both Tier 3 notes are present
- No existing content was accidentally deleted

- [ ] **Step 6: Commit**

```bash
git add core/skills/development-lifecycle.md
git commit -m "feat: add tier routing and Tier 3 EDD notes to development-lifecycle"
```

---

## Task 11: End-to-end smoke test

**Files:** none (validation only)

Verify the full loop can run against a trivial project using the scripts.

- [ ] **Step 1: Create a throwaway test project directory**

```bash
mkdir -p /tmp/edd-smoke-test/.planning
cd /tmp/edd-smoke-test
```

- [ ] **Step 2: Scaffold EVAL.md and LOOP-LOG.md**

```bash
PLANNING_DIR=".planning" \
TEMPLATES_DIR="<absolute-path-to>/core/templates" \
bash <absolute-path-to>/core/scripts/init-eval.sh
```

Expected output:
```
Created .planning/EVAL.md
Created .planning/LOOP-LOG.md
```

- [ ] **Step 3: Fill in EVAL.md with a trivial metric**

Edit `.planning/EVAL.md` and set:
```
**How to run:** echo 75
**Direction:** higher
**Target threshold:** 90
**Delta threshold:** 2
**Stagnation count:** 2
**Time box:** 30
```

- [ ] **Step 4: Run baseline measurement**

```bash
EVAL_FILE=".planning/EVAL.md" bash <path>/core/scripts/run-metric.sh
```

Expected: `75`

- [ ] **Step 5: Append baseline row**

```bash
LOG_FILE=".planning/LOOP-LOG.md" \
bash <path>/core/scripts/append-loop-log.sh 0 "baseline" "—" "75" "—" "—" "—"
```

- [ ] **Step 6: Check stop conditions (should be CONTINUE)**

```bash
EVAL_FILE=".planning/EVAL.md" LOG_FILE=".planning/LOOP-LOG.md" \
python3 <path>/core/scripts/check-stop.py
```

Expected: `CONTINUE`

- [ ] **Step 7: Simulate two stagnant iterations and verify STOP**

```bash
LOG_FILE=".planning/LOOP-LOG.md" \
bash <path>/core/scripts/append-loop-log.sh 1 "try A" 75 76 "+1" "none" "continue"

LOG_FILE=".planning/LOOP-LOG.md" \
bash <path>/core/scripts/append-loop-log.sh 2 "try B" 76 77 "+1" "none" "continue"

EVAL_FILE=".planning/EVAL.md" LOG_FILE=".planning/LOOP-LOG.md" \
python3 <path>/core/scripts/check-stop.py
```

Expected:
```
STOP
CONDITIONS:
- diminishing_returns: 2 consecutive iterations below 2.0 threshold
```

- [ ] **Step 8: Clean up and commit smoke test result**

```bash
cd <repo-root>
rm -rf /tmp/edd-smoke-test
git add .
git commit -m "test: verify end-to-end EDD loop smoke test passes"
```

Only commit if any files changed (e.g., fixes found during smoke test). If nothing changed, skip.

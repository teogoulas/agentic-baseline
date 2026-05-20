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
| 0 | baseline | — | 60 | — | — | — | 2026-05-19 |
"""

# Test 1: CONTINUE when no conditions met
log = LOG_BASE + "| 1 | h1 | 60 | 65 | +5 | none | continue | 2026-05-19 |\n"
out, _ = run(EVAL_BASE, log)
assert_eq("CONTINUE when no conditions met", "CONTINUE", out)

# Test 2: STOP on target reached (higher)
log = LOG_BASE + "| 1 | h1 | 60 | 91 | +31 | none | continue | 2026-05-19 |\n"
out, _ = run(EVAL_BASE, log)
assert_eq("STOP first line on target reached", "STOP", out.splitlines()[0])
assert_contains("mentions target condition", "target", out)

# Test 3: STOP on diminishing returns (2 consecutive below threshold of 2)
log = (LOG_BASE
       + "| 1 | h1 | 60 | 61 | +1 | none | continue | 2026-05-19 |\n"
       + "| 2 | h2 | 61 | 62 | +1 | none | continue | 2026-05-19 |\n")
out, _ = run(EVAL_BASE, log)
assert_eq("STOP first line on diminishing returns", "STOP", out.splitlines()[0])
assert_contains("mentions diminishing_returns", "diminishing_returns", out)

# Test 4: does NOT flag diminishing returns with only 1 iteration below threshold
log = (LOG_BASE
       + "| 1 | h1 | 60 | 65 | +5 | none | continue | 2026-05-19 |\n"
       + "| 2 | h2 | 65 | 66 | +1 | none | continue | 2026-05-19 |\n")
out, _ = run(EVAL_BASE, log)
assert_eq("CONTINUE with only 1 stagnant iteration", "CONTINUE", out)

# Test 5: STOP on time box (start date far in past)
log = LOG_BASE.replace("2026-05-19", "2020-01-01")
out, _ = run(EVAL_BASE, log)
assert_eq("STOP first line on time box", "STOP", out.splitlines()[0])
assert_contains("mentions time_box", "time_box", out)

# Test 6: multiple conditions — all reported
log = (LOG_BASE.replace("2026-05-19", "2020-01-01")
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

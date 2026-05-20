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
COUNT=$(grep -c '^|' "$TMP/.planning/LOOP-LOG.md")
assert_eq "three rows total (header + 2 data)" "3" "$COUNT"

report

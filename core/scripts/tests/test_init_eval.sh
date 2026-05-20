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

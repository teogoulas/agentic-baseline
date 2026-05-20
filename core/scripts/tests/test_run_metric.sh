#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"
RUN_SCRIPT="$SCRIPT_DIR/../run-metric.sh"

echo "--- test_run_metric ---"

# Test 1: runs command and outputs numeric result
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
OUT=$(EVAL_FILE="/no/such/file" bash "$RUN_SCRIPT" 2>&1) || true
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
